import { ProductModel, IProduct } from './product.model';
import { CategoryModel, ICategory } from './category.model';
import { ApiError } from '../../utils/apiError';

export class ProductService {
  static async getCategories(): Promise<ICategory[]> {
    return CategoryModel.find({ isActive: true }).sort({ name: 1 });
  }

  static async createCategory(data: { name: string; description?: string }): Promise<ICategory> {
    const slug = data.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
    const existing = await CategoryModel.findOne({ slug });
    if (existing) {
      throw ApiError.badRequest('Category already exists');
    }
    return CategoryModel.create({ ...data, slug });
  }

  static async getProducts(query: { search?: string; category?: string }): Promise<IProduct[]> {
    const filter: any = {};

    if (query.search) {
      const searchRegex = new RegExp(query.search, 'i');
      filter.$or = [
        { name: searchRegex },
        { sku: searchRegex },
        { barcode: searchRegex },
        { categoryName: searchRegex },
      ];
    }

    if (query.category && query.category !== 'All') {
      filter.categoryName = query.category;
    }

    return ProductModel.find(filter).sort({ createdAt: -1 });
  }

  static async getProductById(id: string): Promise<IProduct> {
    const product = await ProductModel.findById(id);
    if (!product) {
      throw ApiError.notFound('Product not found');
    }
    return product;
  }

  static async createProduct(data: Partial<IProduct>): Promise<IProduct> {
    const existingSku = await ProductModel.findOne({ sku: data.sku });
    if (existingSku) {
      throw ApiError.badRequest(`Product with SKU '${data.sku}' already exists`);
    }

    // Auto-compute status
    let status: 'AVAILABLE' | 'LOW_STOCK' | 'OUT_OF_STOCK' = 'AVAILABLE';
    const stock = data.stockQuantity || 0;
    const minLevel = data.minStockLevel || 5;
    if (stock <= 0) status = 'OUT_OF_STOCK';
    else if (stock <= minLevel) status = 'LOW_STOCK';

    return ProductModel.create({
      ...data,
      status,
    });
  }

  static async updateProduct(id: string, data: Partial<IProduct>): Promise<IProduct> {
    const product = await ProductModel.findById(id);
    if (!product) {
      throw ApiError.notFound('Product not found');
    }

    if (data.sku && data.sku !== product.sku) {
      const existingSku = await ProductModel.findOne({ sku: data.sku });
      if (existingSku) {
        throw ApiError.badRequest(`Product with SKU '${data.sku}' already exists`);
      }
    }

    Object.assign(product, data);

    // Recompute status
    if (product.stockQuantity <= 0) {
      product.status = 'OUT_OF_STOCK';
    } else if (product.stockQuantity <= product.minStockLevel) {
      product.status = 'LOW_STOCK';
    } else {
      product.status = 'AVAILABLE';
    }

    await product.save();
    return product;
  }

  static async deleteProduct(id: string): Promise<void> {
    const product = await ProductModel.findByIdAndDelete(id);
    if (!product) {
      throw ApiError.notFound('Product not found');
    }
  }
}
