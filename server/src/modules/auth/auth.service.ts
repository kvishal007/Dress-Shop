import { User } from '../users/user.model';
import { ApiError } from '../../utils/apiError';
import { comparePassword } from '../../utils/password';
import { generateToken } from '../../utils/jwt';
import { UserStatusEnum } from '../users/user.interface';

export class AuthService {
  static async login(email: string, password: string, ipAddress?: string) {
    const user = await User.findOne({ email: email.toLowerCase() }).select('+password');
    if (!user) {
      throw ApiError.unauthorized('Invalid email or password');
    }

    if (user.status !== UserStatusEnum.ACTIVE) {
      throw ApiError.forbidden('Your account is inactive. Please contact system administrator.');
    }

    const isMatch = await comparePassword(password, user.password);
    if (!isMatch) {
      throw ApiError.unauthorized('Invalid email or password');
    }

    // Update last login
    user.lastLogin = new Date();
    await user.save();

    const token = generateToken({
      userId: (user._id as any).toString(),
      email: user.email,
      role: user.role,
    });

    const userObj = user.toObject();
    delete (userObj as any).password;

    return {
      user: userObj,
      token,
    };
  }

  static async getMe(userId: string) {
    const user = await User.findById(userId);
    if (!user) {
      throw ApiError.notFound('User not found');
    }
    return user;
  }
}
