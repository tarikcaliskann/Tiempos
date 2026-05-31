type BrandLogoProps = {
  className?: string;
  alt?: string;
};

export function BrandLogo({ className, alt = "Tiempos logo" }: BrandLogoProps) {
  return (
    <img
      src="/logo.png"
      alt={alt}
      className={className}
      loading="eager"
      decoding="async"
    />
  );
}
