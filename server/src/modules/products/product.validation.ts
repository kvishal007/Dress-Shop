import { z } from 'zod';

export const createCategorySchema = z.object({
  body: z.object({
    name: z.string().min(2, 'Category name must be at least 2 characters'),
    description: z.string().optional(),
  }),
});

export const createProductSchema = z.object({
  body: z.object({
    name: z.string().min(2, 'Product name must be at least 2 characters'),
    sku: z.string().min(2, 'SKU must be at least 2 characters'),
    barcode: z.string().optional(),
    categoryId: z.string().optional(),
    categoryName: z.string().optional().default('General'),
    description: z.string().optional(),
    price: z.number().positive('Price must be greater than 0'),
    costPrice: z.number().nonnegative().optional().default(0),
    stockQuantity: z.number().int().nonnegative('Stock quantity cannot be negative'),
    minStockLevel: z.number().int().nonnegative().optional().default(5),
    sizes: z.array(z.string()).optional().default([]),
    colors: z.array(z.string()).optional().default([]),
    imageUrl: z.string().optional(),
  }),
});

export const updateProductSchema = z.object({
  body: z.object({
    name: z.string().min(2).optional(),
    sku: z.string().min(2).optional(),
    barcode: z.string().optional(),
    categoryId: z.string().optional(),
    categoryName: z.string().optional(),
    description: z.string().optional(),
    price: z.number().positive().optional(),
    costPrice: z.number().nonnegative().optional(),
    stockQuantity: z.number().int().nonnegative().optional(),
    minStockLevel: z.number().int().nonnegative().optional(),
    sizes: z.array(z.string()).optional(),
    colors: z.array(z.string()).optional(),
    imageUrl: z.string().optional(),
  }),
});
