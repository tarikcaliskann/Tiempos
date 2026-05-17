import { useEffect, useState } from "react";
import {
  ArrowLeft,
  Check,
  CheckCircle,
  CreditCard,
  Loader2,
  Lock,
  XCircle,
} from "lucide-react";
import { PageLayout } from "../components/layout/PageLayout";
import type { PageType } from "../App";
import { useLanguage } from "../contexts/LanguageContext";
import { useAuth } from "../contexts/AuthContext";
import { formatTemplate } from "../language";
import {
  completeCreditPurchase,
  startCreditCheckout,
} from "../api/credits";
import { apiErrorDisplayMessage } from "../api/client";
import {
  SELECTED_PACKAGE_KEY,
  type CreditPackage,
} from "../data/creditPackages";
import "../styles/payment.css";

interface PaymentPageProps {
  onNavigate?: (page: PageType) => void;
}

type PaymentStatus = "form" | "processing" | "success" | "error";

type PaymentLocale = typeof import("../language/locale/tr").tr.payment;

export function PaymentPage({ onNavigate }: PaymentPageProps) {
  const { t } = useLanguage();
  const p = t.payment;
  const { token } = useAuth();
  const [selectedPackage, setSelectedPackage] = useState<CreditPackage | null>(
    null,
  );
  const [paymentStatus, setPaymentStatus] = useState<PaymentStatus>("form");
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [resultHours, setResultHours] = useState(0);
  const [resultAmount, setResultAmount] = useState(0);

  const [cardNumber, setCardNumber] = useState("");
  const [cardName, setCardName] = useState("");
  const [expiryDate, setExpiryDate] = useState("");
  const [cvv, setCvv] = useState("");

  useEffect(() => {
    try {
      const raw = localStorage.getItem(SELECTED_PACKAGE_KEY);
      if (raw) {
        setSelectedPackage(JSON.parse(raw) as CreditPackage);
        return;
      }
    } catch {
      /* ignore */
    }
    onNavigate?.("buy-credits");
  }, [onNavigate]);

  const formatCardNumber = (value: string) => {
    const cleaned = value.replace(/\s/g, "");
    const groups = cleaned.match(/.{1,4}/g);
    return groups ? groups.join(" ") : cleaned;
  };

  const handleCardNumberChange = (value: string) => {
    const cleaned = value.replace(/\s/g, "");
    if (cleaned.length <= 16 && /^\d*$/.test(cleaned)) {
      setCardNumber(formatCardNumber(cleaned));
    }
  };

  const handleExpiryChange = (value: string) => {
    let v = value.replace(/\D/g, "");
    if (v.length >= 2) v = `${v.slice(0, 2)}/${v.slice(2, 4)}`;
    if (v.length <= 5) setExpiryDate(v);
  };

  const handleCvvChange = (value: string) => {
    if (value.length <= 3 && /^\d*$/.test(value)) setCvv(value);
  };

  const isFormValid = () =>
    cardNumber.replace(/\s/g, "").length === 16 &&
    cardName.trim().length > 0 &&
    expiryDate.length === 5 &&
    cvv.length === 3;

  const processPayment = async () => {
    if (!selectedPackage || !token || !isFormValid()) return;
    setErrorMessage(null);
    setPaymentStatus("processing");

    try {
      const session = await startCreditCheckout(selectedPackage.id, token);

      if (session.checkoutUrl && !session.demoMode) {
        window.location.href = session.checkoutUrl;
        return;
      }

      await new Promise((r) => setTimeout(r, 3000));

      if (Math.random() < 0.1) {
        setErrorMessage(p.failedMessage);
        setPaymentStatus("error");
        return;
      }

      const result = await completeCreditPurchase(session.sessionId, token);
      localStorage.removeItem(SELECTED_PACKAGE_KEY);
      setResultHours(result.displayHours);
      setResultAmount(result.amountTry);
      setPaymentStatus("success");
    } catch (err) {
      setErrorMessage(apiErrorDisplayMessage(err, p.failedMessage));
      setPaymentStatus("error");
    }
  };

  const handleRetry = () => {
    setPaymentStatus("form");
    setErrorMessage(null);
    setCardNumber("");
    setCardName("");
    setExpiryDate("");
    setCvv("");
  };

  if (!selectedPackage) {
    return <PaymentPageLoading />;
  }

  const features =
    p.packageFeatures?.[
      selectedPackage.id as keyof typeof p.packageFeatures
    ] ?? selectedPackage.features;

  return (
    <PageLayout onNavigate={onNavigate} className="payment-page">
      <div className="payment-page__wrap">
        {paymentStatus !== "success" && (
          <PaymentPageHeader p={p} onBack={() => onNavigate?.("buy-credits")} />
        )}

        {paymentStatus === "form" && (
          <PaymentFormGrid
            p={p}
            pkg={selectedPackage}
            features={features}
            cardNumber={cardNumber}
            cardName={cardName}
            expiryDate={expiryDate}
            cvv={cvv}
            token={token}
            isFormValid={isFormValid()}
            onCardNumber={handleCardNumberChange}
            onCardName={setCardName}
            onExpiry={handleExpiryChange}
            onCvv={handleCvvChange}
            onSubmit={processPayment}
          />
        )}

        {paymentStatus === "processing" && <ProcessingStatus p={p} />}

        {paymentStatus === "success" && (
          <SuccessStatus
            p={p}
            hours={resultHours}
            amount={resultAmount}
            onDashboard={() => onNavigate?.("dashboard")}
          />
        )}

        {paymentStatus === "error" && (
          <PaymentErrorLayout
            p={p}
            pkg={selectedPackage}
            features={features}
            message={errorMessage ?? p.failedMessage}
            onRetry={handleRetry}
            onBack={() => onNavigate?.("buy-credits")}
          />
        )}
      </div>
    </PageLayout>
  );
}

function PaymentPageLoading() {
  return (
    <div className="payment-page__loading">
      <Loader2 className="payment-page__loading-icon" />
    </div>
  );
}

function PaymentPageHeader({
  p,
  onBack,
}: {
  p: Pick<PaymentLocale, "back" | "title" | "subtitle">;
  onBack: () => void;
}) {
  return (
    <header className="payment-page__header">
      <button type="button" className="payment-page__back" onClick={onBack}>
        <ArrowLeft className="h-4 w-4" aria-hidden />
        {p.back}
      </button>
      <h1 className="payment-page__title">{p.title}</h1>
      <p className="payment-page__subtitle">{p.subtitle}</p>
    </header>
  );
}

function PaymentFormGrid({
  p,
  pkg,
  features,
  cardNumber,
  cardName,
  expiryDate,
  cvv,
  token,
  isFormValid,
  onCardNumber,
  onCardName,
  onExpiry,
  onCvv,
  onSubmit,
}: {
  p: PaymentLocale;
  pkg: CreditPackage;
  features: string[];
  cardNumber: string;
  cardName: string;
  expiryDate: string;
  cvv: string;
  token: string | null;
  isFormValid: boolean;
  onCardNumber: (v: string) => void;
  onCardName: (v: string) => void;
  onExpiry: (v: string) => void;
  onCvv: (v: string) => void;
  onSubmit: () => void;
}) {
  return (
    <div className="payment-page__grid">
      <div className="payment-card">
        <span className="payment-badge payment-badge--secure">
          <Lock className="h-3.5 w-3.5" aria-hidden />
          {p.secureBadge}
        </span>

        <form
          onSubmit={(e) => {
            e.preventDefault();
            onSubmit();
          }}
        >
          <div className="payment-form__group">
            <label className="payment-form__label" htmlFor="card-number">
              {p.cardNumber}
            </label>
            <div className="payment-form__input-wrap">
              <CreditCard className="payment-form__input-icon" aria-hidden />
              <input
                id="card-number"
                type="text"
                inputMode="numeric"
                autoComplete="cc-number"
                className="payment-form__input payment-form__input--icon"
                placeholder="1234 5678 9012 3456"
                value={cardNumber}
                onChange={(e) => onCardNumber(e.target.value)}
              />
            </div>
          </div>

          <div className="payment-form__group">
            <label className="payment-form__label" htmlFor="card-name">
              {p.cardName}
            </label>
            <input
              id="card-name"
              type="text"
              autoComplete="cc-name"
              className="payment-form__input"
              placeholder={p.cardNamePlaceholder}
              value={cardName}
              onChange={(e) => onCardName(e.target.value.toUpperCase())}
            />
          </div>

          <ExpiryCvvRow
            p={p}
            expiryDate={expiryDate}
            cvv={cvv}
            onExpiry={onExpiry}
            onCvv={onCvv}
          />

          <button
            type="submit"
            className="payment-form__submit"
            disabled={!isFormValid || !token}
          >
            <Lock className="h-4 w-4" aria-hidden />
            {formatTemplate(p.payButton, { amount: pkg.discountedPrice })}
          </button>

          {!token && (
            <p className="payment-form__footer-note text-red-600">
              {p.authRequired}
            </p>
          )}
          <p className="payment-form__footer-note">{p.securityNote}</p>
        </form>
      </div>

      <OrderSummary p={p} pkg={pkg} features={features} />
    </div>
  );
}

function ExpiryCvvRow({
  p,
  expiryDate,
  cvv,
  onExpiry,
  onCvv,
}: {
  p: PaymentLocale;
  expiryDate: string;
  cvv: string;
  onExpiry: (v: string) => void;
  onCvv: (v: string) => void;
}) {
  return (
    <div className="payment-form__row">
      <div className="payment-form__group">
        <label className="payment-form__label" htmlFor="expiry">
          {p.expiry}
        </label>
        <input
          id="expiry"
          type="text"
          inputMode="numeric"
          autoComplete="cc-exp"
          className="payment-form__input"
          placeholder="MM/YY"
          value={expiryDate}
          onChange={(e) => onExpiry(e.target.value)}
        />
      </div>
      <div className="payment-form__group">
        <label className="payment-form__label" htmlFor="cvv">
          {p.cvv}
        </label>
        <input
          id="cvv"
          type="text"
          inputMode="numeric"
          autoComplete="cc-csc"
          className="payment-form__input"
          placeholder="123"
          value={cvv}
          onChange={(e) => onCvv(e.target.value)}
        />
      </div>
    </div>
  );
}

function OrderSummary({
  p,
  pkg,
  features,
}: {
  p: PaymentLocale;
  pkg: CreditPackage;
  features: string[];
}) {
  const discountAmount = pkg.originalPrice - pkg.discountedPrice;

  return (
    <div className="payment-card">
      <h2 className="payment-summary__title">{p.orderSummary}</h2>

      <div className="payment-summary__row">
        <span>{p.packageLabel}</span>
        <span className="payment-summary__value">
          {pkg.hours} {p.hourUnit}
        </span>
      </div>

      {pkg.discount > 0 && (
        <>
          <div className="payment-summary__divider" />
          <DiscountSummaryRows
            p={p}
            pkg={pkg}
            discountAmount={discountAmount}
          />
        </>
      )}

      <div className="payment-summary__divider" />

      <div className="payment-summary__total">
        <span>{p.total}</span>
        <span className="payment-summary__total-price">
          {pkg.discountedPrice} ₺
        </span>
      </div>

      <div className="payment-summary__divider" />

      <h3 className="payment-summary__features-title">{p.includedTitle}</h3>
      <ul className="payment-summary__features">
        {features.map((feature, i) => (
          <li key={i} className="payment-summary__feature">
            <Check className="payment-summary__check" strokeWidth={2.5} />
            <span>{feature}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}

function DiscountSummaryRows({
  p,
  pkg,
  discountAmount,
}: {
  p: PaymentLocale;
  pkg: CreditPackage;
  discountAmount: number;
}) {
  return (
    <>
      <div className="payment-summary__row payment-summary__row--old">
        <span>{p.listPrice}</span>
        <span className="payment-summary__value">{pkg.originalPrice} ₺</span>
      </div>
      <div className="payment-summary__row payment-summary__row--discount">
        <span>{p.discountLabel}</span>
        <span className="payment-summary__value">-{discountAmount} ₺</span>
      </div>
    </>
  );
}

function ProcessingStatus({
  p,
}: {
  p: Pick<PaymentLocale, "processingTitle" | "processingMessage">;
}) {
  return (
    <div className="payment-card payment-status">
      <div className="payment-status__icon-wrap">
        <Loader2 className="payment-status__icon payment-status__icon--spin" />
      </div>
      <h2 className="payment-status__title">{p.processingTitle}</h2>
      <p className="payment-status__message">{p.processingMessage}</p>
      <div className="payment-status__bar">
        <div className="payment-status__bar-fill" />
      </div>
    </div>
  );
}

function SuccessStatus({
  p,
  hours,
  amount,
  onDashboard,
}: {
  p: Pick<
    PaymentLocale,
    | "successTitle"
    | "successMessage"
    | "amountLabel"
    | "creditLabel"
    | "hourUnit"
    | "backToDashboard"
  >;
  hours: number;
  amount: number;
  onDashboard: () => void;
}) {
  return (
    <div className="payment-card payment-status">
      <div className="payment-status__icon-wrap">
        <CheckCircle className="payment-status__icon text-green-500" />
      </div>
      <h2 className="payment-status__title">{p.successTitle}</h2>
      <p className="payment-status__message">
        {formatTemplate(p.successMessage, { hours })}
      </p>
      <div className="payment-status__details">
        <div className="payment-status__detail-row">
          <span>{p.amountLabel}</span>
          <strong>{amount} ₺</strong>
        </div>
        <div className="payment-status__detail-row">
          <span>{p.creditLabel}</span>
          <strong>
            {hours} {p.hourUnit}
          </strong>
        </div>
      </div>
      <button
        type="button"
        className="payment-status__btn payment-status__btn--success"
        onClick={onDashboard}
      >
        {p.backToDashboard}
      </button>
    </div>
  );
}

function PaymentErrorLayout({
  p,
  pkg,
  features,
  message,
  onRetry,
  onBack,
}: {
  p: PaymentLocale;
  pkg: CreditPackage;
  features: string[];
  message: string;
  onRetry: () => void;
  onBack: () => void;
}) {
  return (
    <div className="payment-page__grid">
      <ErrorPanel p={p} message={message} onRetry={onRetry} onBack={onBack} />
      <OrderSummary p={p} pkg={pkg} features={features} />
    </div>
  );
}

function ErrorPanel({
  p,
  message,
  onRetry,
  onBack,
}: {
  p: PaymentLocale;
  message: string;
  onRetry: () => void;
  onBack: () => void;
}) {
  return (
    <div className="payment-card">
      <span className="payment-badge payment-badge--failed">
        <XCircle className="h-3.5 w-3.5" aria-hidden />
        {p.failedBadge}
      </span>

      <div style={{ textAlign: "left" }}>
        <div
          className="payment-status__icon-wrap"
          style={{ justifyContent: "flex-start" }}
        >
          <XCircle className="payment-status__icon text-red-500" />
        </div>
        <h2 className="payment-status__title">{p.failedTitle}</h2>
        <p className="payment-status__message">{message}</p>

        <div className="payment-status__reasons">
          <p className="payment-status__reasons-title">{p.failureReasonsTitle}</p>
          <ul>
            {p.failureReasons.map((reason, i) => (
              <li key={i}>{reason}</li>
            ))}
          </ul>
        </div>

        <div className="payment-status__actions payment-status__actions--row">
          <button
            type="button"
            className="payment-status__btn payment-status__btn--primary"
            onClick={onRetry}
          >
            {p.retry}
          </button>
          <button
            type="button"
            className="payment-status__btn payment-status__btn--outline"
            onClick={onBack}
          >
            {p.backToPackages}
          </button>
        </div>
      </div>
    </div>
  );
}
