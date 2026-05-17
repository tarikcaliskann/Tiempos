import { useState } from "react";
import { Check, CreditCard, Sparkles } from "lucide-react";
import { PageLayout } from "../components/layout/PageLayout";
import type { PageType } from "../App";
import { useLanguage } from "../contexts/LanguageContext";
import {
  CREDIT_PACKAGES,
  SELECTED_PACKAGE_KEY,
} from "../data/creditPackages";
import "../styles/buy-credits.css";

interface BuyCreditsPageProps {
  onNavigate?: (page: PageType) => void;
}

export function BuyCreditsPage({ onNavigate }: BuyCreditsPageProps) {
  const { t } = useLanguage();
  const b = t.buyCredits;
  const [selectedPackage, setSelectedPackage] = useState<string | null>(null);

  const handleProceedToPayment = () => {
    if (!selectedPackage || !onNavigate) return;
    const selected = CREDIT_PACKAGES.find((p) => p.id === selectedPackage);
    if (selected) {
      try {
        localStorage.setItem(SELECTED_PACKAGE_KEY, JSON.stringify(selected));
      } catch {
        /* ignore */
      }
      onNavigate("payment");
    }
  };

  return (
    <PageLayout onNavigate={onNavigate} className="buy-credits-page">
      <section className="buy-credits-hero px-4 sm:px-6 lg:px-8">
        <CreditsHero b={b} />
      </section>

      <main className="buy-credits-main">
        <div className="buy-credits-campaign">
          <Sparkles
            className="mt-0.5 h-5 w-5 shrink-0 sm:h-6 sm:w-6"
            aria-hidden
          />
          <div>
            <h3 className="buy-credits-campaign__title">{b.campaignTitle}</h3>
            <p className="buy-credits-campaign__text">{b.campaignText}</p>
          </div>
        </div>

        <div className="buy-credits-grid">
          {CREDIT_PACKAGES.map((pkg) => (
            <PackageCard
              key={pkg.id}
              pkg={pkg}
              b={b}
              selected={selectedPackage === pkg.id}
              onSelect={() => setSelectedPackage(pkg.id)}
            />
          ))}
        </div>

        <div className="buy-credits-checkout">
          <button
            type="button"
            className="buy-credits-checkout__btn"
            disabled={!selectedPackage}
            onClick={handleProceedToPayment}
          >
            <CreditCard className="h-4 w-4" aria-hidden />
            {b.proceedToPayment}
          </button>
          {!selectedPackage && (
            <p className="buy-credits-checkout__hint">{b.selectHint}</p>
          )}
          <p className="buy-credits-checkout__security">{b.securityNote}</p>
        </div>
      </main>
    </PageLayout>
  );
}

function CreditsHero({ b }: { b: { title: string; subtitle: string } }) {
  return (
    <div className="mx-auto max-w-2xl text-center">
      <div className="buy-credits-hero__icon">
        <CreditCard className="h-9 w-9 text-white" strokeWidth={1.5} />
      </div>
      <h1 className="buy-credits-hero__title">{b.title}</h1>
      <p className="buy-credits-hero__subtitle">{b.subtitle}</p>
    </div>
  );
}

function PackageCard({
  pkg,
  b,
  selected,
  onSelect,
}: {
  pkg: (typeof CREDIT_PACKAGES)[number];
  b: typeof import("../language/locale/tr").tr.buyCredits;
  selected: boolean;
  onSelect: () => void;
}) {
  const features =
    b.packageFeatures[pkg.id as keyof typeof b.packageFeatures] ?? pkg.features;
  const badge =
    pkg.badge && (b.badges[pkg.id as keyof typeof b.badges] ?? pkg.badge);

  return (
    <article
      role="button"
      tabIndex={0}
      onClick={onSelect}
      onKeyDown={(e) => {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          onSelect();
        }
      }}
      className={
        selected
          ? "buy-credits-card buy-credits-card--selected"
          : "buy-credits-card"
      }
      aria-pressed={selected}
    >
      {badge && <span className="buy-credits-card__badge">{badge}</span>}

      <h3 className="buy-credits-card__title">
        {pkg.hours} {b.hourUnit}
      </h3>

      <div className="buy-credits-card__pricing">
        {pkg.discount > 0 && (
          <p className="buy-credits-card__price-old">
            {pkg.originalPrice} {b.currency}
          </p>
        )}
        <p className="buy-credits-card__price">
          {pkg.discountedPrice}{" "}
          <span className="buy-credits-card__price-currency">{b.currency}</span>
        </p>
        {pkg.discount > 0 && (
          <span className="buy-credits-card__discount">
            %{pkg.discount} {b.discountLabel}
          </span>
        )}
      </div>

      <ul className="buy-credits-card__features">
        {features.map((feature, index) => (
          <li key={index} className="buy-credits-card__feature">
            <Check className="buy-credits-card__check" strokeWidth={2.5} />
            <span>{feature}</span>
          </li>
        ))}
      </ul>

      <div className="buy-credits-card__footer">
        <span
          className={
            selected
              ? "buy-credits-card__radio buy-credits-card__radio--on"
              : "buy-credits-card__radio"
          }
          aria-hidden
        />
        <span
          className={
            selected
              ? "buy-credits-card__select-label buy-credits-card__select-label--on"
              : "buy-credits-card__select-label"
          }
        >
          {selected ? b.selected : b.select}
        </span>
      </div>
    </article>
  );
}
