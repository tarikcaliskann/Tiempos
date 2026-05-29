// Web `howItWorks` / `staticSite` / `faqPage` / `contactPage` ile uyumlu veri modelleri.

class HowItWorksStep {
  const HowItWorksStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;
}

class HowItWorksCopy {
  const HowItWorksCopy({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.getStartedFree,
    required this.stepsTitle,
    required this.stepsSubtitle,
    required this.steps,
    required this.creditsTitle,
    required this.creditsIntro,
    required this.teachHour,
    required this.teachHourSub,
    required this.learnHour,
    required this.learnHourSub,
    required this.bonusTitle,
    required this.bonusCredits,
    required this.bonusDesc,
    required this.claimBonus,
    required this.whyTitle,
    required this.benefits,
    required this.faqTitle,
    required this.miniFaqs,
    required this.ctaTitle,
    required this.ctaSubtitle,
    required this.ctaButton,
  });

  final String heroTitle;
  final String heroSubtitle;
  final String getStartedFree;
  final String stepsTitle;
  final String stepsSubtitle;
  final List<HowItWorksStep> steps;
  final String creditsTitle;
  final String creditsIntro;
  final String teachHour;
  final String teachHourSub;
  final String learnHour;
  final String learnHourSub;
  final String bonusTitle;
  final String bonusCredits;
  final String bonusDesc;
  final String claimBonus;
  final String whyTitle;
  final List<String> benefits;
  final String faqTitle;
  final List<({String q, String a})> miniFaqs;
  final String ctaTitle;
  final String ctaSubtitle;
  final String ctaButton;
}

class AboutValue {
  const AboutValue({required this.title, required this.body});

  final String title;
  final String body;
}

class AboutCopy {
  const AboutCopy({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.missionTitle,
    required this.missionP1,
    required this.missionP2,
    required this.statMembers,
    required this.statSkills,
    required this.statHours,
    required this.statSatisfaction,
    required this.valuesTitle,
    required this.values,
    required this.storyTitle,
    required this.storyParagraphs,
    required this.ctaTitle,
    required this.ctaSubtitle,
    required this.ctaButton,
  });

  final String heroTitle;
  final String heroSubtitle;
  final String missionTitle;
  final String missionP1;
  final String missionP2;
  final String statMembers;
  final String statSkills;
  final String statHours;
  final String statSatisfaction;
  final String valuesTitle;
  final List<AboutValue> values;
  final String storyTitle;
  final List<String> storyParagraphs;
  final String ctaTitle;
  final String ctaSubtitle;
  final String ctaButton;
}

class FaqCategory {
  const FaqCategory({required this.id, required this.label});

  final String id;
  final String label;
}

class FaqItem {
  const FaqItem({
    required this.id,
    required this.category,
    required this.q,
    required this.a,
  });

  final int id;
  final String category;
  final String q;
  final String a;
}

class FaqPageCopy {
  const FaqPageCopy({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.searchPlaceholder,
    required this.emptyText,
    required this.ctaTitle,
    required this.ctaText,
    required this.ctaButton,
    required this.categories,
    required this.items,
  });

  final String heroTitle;
  final String heroSubtitle;
  final String searchPlaceholder;
  final String emptyText;
  final String ctaTitle;
  final String ctaText;
  final String ctaButton;
  final List<FaqCategory> categories;
  final List<FaqItem> items;
}

class StaticTwoField {
  const StaticTwoField({required this.title, required this.body});

  final String title;
  final String body;
}

class LegalDocCopy {
  const LegalDocCopy({
    required this.title,
    required this.heroSubtitle,
    required this.body,
  });

  final String title;
  final String heroSubtitle;
  final String body;
}

class ContactPageCopy {
  const ContactPageCopy({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.infoTitle,
    required this.infoIntro,
    required this.emailTitle,
    required this.emailAddress,
    required this.responseTitle,
    required this.responseText,
    required this.formTitle,
    required this.labelName,
    required this.labelEmail,
    required this.labelSubject,
    required this.labelMessage,
    required this.placeholderName,
    required this.placeholderEmail,
    required this.placeholderMessage,
    required this.subjectPlaceholder,
    required this.subjectGeneral,
    required this.subjectSupport,
    required this.subjectBilling,
    required this.subjectPartnership,
    required this.subjectFeedback,
    required this.subjectOther,
    required this.sendButton,
    required this.sending,
    required this.successTitle,
    required this.successText,
    required this.errorSend,
    required this.errorSendAuth,
    required this.errorSendNotFound,
    required this.errorUnavailable,
    required this.errorSmtpNotReady,
    required this.errorSmtpSendFailed,
    required this.faqSectionTitle,
    required this.faqSectionText,
    required this.faqButton,
  });

  final String heroTitle;
  final String heroSubtitle;
  final String infoTitle;
  final String infoIntro;
  final String emailTitle;
  final String emailAddress;
  final String responseTitle;
  final String responseText;
  final String formTitle;
  final String labelName;
  final String labelEmail;
  final String labelSubject;
  final String labelMessage;
  final String placeholderName;
  final String placeholderEmail;
  final String placeholderMessage;
  final String subjectPlaceholder;
  final String subjectGeneral;
  final String subjectSupport;
  final String subjectBilling;
  final String subjectPartnership;
  final String subjectFeedback;
  final String subjectOther;
  final String sendButton;
  final String sending;
  final String successTitle;
  final String successText;
  final String errorSend;
  final String errorSendAuth;
  final String errorSendNotFound;
  final String errorUnavailable;
  final String errorSmtpNotReady;
  final String errorSmtpSendFailed;
  final String faqSectionTitle;
  final String faqSectionText;
  final String faqButton;
}

class HelpCenterBundle {
  const HelpCenterBundle({
    required this.howItWorks,
    required this.about,
    required this.faq,
    required this.community,
    required this.contact,
    required this.support,
    required this.terms,
    required this.privacy,
    required this.policyCancellation,
    required this.instructorGuide,
  });

  final HowItWorksCopy howItWorks;
  final AboutCopy about;
  final FaqPageCopy faq;
  final StaticTwoField community;
  final ContactPageCopy contact;
  final StaticTwoField support;
  final LegalDocCopy terms;
  final LegalDocCopy privacy;
  final LegalDocCopy policyCancellation;
  final StaticTwoField instructorGuide;
}
