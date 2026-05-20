type BrandLogoProps = {
  className?: string;
  alt?: string;
};

export function BrandLogo({ className, alt = "Tiempos logo" }: BrandLogoProps) {
  return (
    <img
      src="/logo.svg"
      alt={alt}
      className={className}
      loading="eager"
      decoding="async"
    />
  );
}
