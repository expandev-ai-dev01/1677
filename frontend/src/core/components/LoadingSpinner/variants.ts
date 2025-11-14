import { clsx } from 'clsx';

export interface LoadingSpinnerVariantProps {
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

export function getLoadingSpinnerClassName(props: LoadingSpinnerVariantProps): string {
  const { size = 'md', className } = props;

  return clsx(
    'animate-spin rounded-full border-2 border-gray-300 border-t-blue-600',
    {
      'h-6 w-6': size === 'sm',
      'h-10 w-10': size === 'md',
      'h-16 w-16': size === 'lg',
    },
    className
  );
}
