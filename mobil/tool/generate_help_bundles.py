#!/usr/bin/env python3
"""Emit mobil/lib/help/help_bundle_en.dart and help_bundle_tr.dart from embedded web copy."""
from __future__ import annotations

import json
import textwrap
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_EN = ROOT / "lib" / "help" / "help_bundle_en.dart"
OUT_TR = ROOT / "lib" / "help" / "help_bundle_tr.dart"

# --- English (frontend en.ts + faq-page-en.ts excerpts) ---
EN = {
    "howItWorks": {
        "heroTitle": "How Tiempos Works",
        "heroSubtitle": "A simple, fair way to exchange skills and build your community",
        "getStartedFree": "Get Started Free",
        "stepsTitle": "Four Simple Steps",
        "stepsSubtitle": "Start your learning journey in minutes",
        "steps": [
            {
                "number": "01",
                "title": "Create Your Profile",
                "description": "Sign up and tell us about your skills and what you'd like to learn. It takes just 2 minutes to get started.",
            },
            {
                "number": "02",
                "title": "Browse & Connect",
                "description": "Explore hundreds of skills offered by our community. Find the perfect match based on your interests and schedule.",
            },
            {
                "number": "03",
                "title": "Exchange Skills",
                "description": "Teach what you know and learn what you want. Every hour you teach earns you time credits to spend on learning.",
            },
            {
                "number": "04",
                "title": "Grow Together",
                "description": "Build your profile and become part of a thriving community of lifelong learners.",
            },
        ],
        "creditsTitle": "Understanding Time Credits",
        "creditsIntro": "Time credits are the currency of Tiempos. The system is beautifully simple:",
        "teachHour": "1 Hour Teaching = 1 Time Credit",
        "teachHourSub": "Earn credits by sharing your knowledge",
        "learnHour": "1 Time Credit = 1 Hour Learning",
        "learnHourSub": "Spend credits to learn anything",
        "bonusTitle": "New Member Bonus",
        "bonusCredits": "Get 1 Free Time Credit",
        "bonusDesc": "New members start with 1 time credit (1 hour of learning). Begin right away — no teaching required first.",
        "claimBonus": "Claim Your Bonus",
        "whyTitle": "Why Choose Tiempos?",
        "benefits": [
            "No money needed - trade time for time",
            "Learn from passionate experts in your community",
            "Flexible scheduling - learn at your own pace",
            "Build meaningful connections",
            "Safe and verified community members",
            "Track your learning progress",
        ],
        "faqTitle": "Frequently Asked Questions",
        "miniFaqs": [
            {
                "q": "How do time credits work?",
                "a": "For every hour you teach, you earn one time credit. You can then spend these credits to learn from others. It's a fair, equal exchange system.",
            },
            {
                "q": "What if I don't have any skills to teach?",
                "a": "Everyone has something valuable to share! Whether it's cooking, gardening, a language you speak, or professional expertise - all skills are welcome on Tiempos.",
            },
            {
                "q": "Can I learn and teach at the same time?",
                "a": "Absolutely! Most of our members are both teachers and students. You can offer your skills while simultaneously learning new ones.",
            },
            {
                "q": "Is Tiempos free to use?",
                "a": "Yes! Creating an account and exchanging skills is completely free. We believe in making learning accessible to everyone.",
            },
            {
                "q": "How do I get my first time credits?",
                "a": "New members receive 1 free hour of time credit to begin learning right away. You can also start teaching to earn more credits immediately.",
            },
        ],
        "ctaTitle": "Ready to Start Learning?",
        "ctaSubtitle": "Join thousands of learners and teachers in our community",
        "ctaButton": "Create Free Account",
    },
    "about": {
        "heroTitle": "About Tiempos",
        "heroSubtitle": "Building a community where time is the currency and skills are shared freely",
        "missionTitle": "Our Mission",
        "missionP1": "Tiempos was born from a simple yet powerful idea: everyone has something valuable to teach, and everyone has something they want to learn. We believe that knowledge shouldn't be locked behind financial barriers.",
        "missionP2": "Our platform enables people to exchange skills using time as currency. One hour of your time teaching equals one hour of learning from someone else. It's fair, it's simple, and it builds genuine connections.",
        "statMembers": "Verified members",
        "statSkills": "Skills listed",
        "statHours": "Hours exchanged (completed)",
        "statSatisfaction": "Satisfaction (from reviews)",
        "valuesTitle": "Our Values",
        "values": [
            {
                "title": "Community First",
                "body": "We believe in building strong, supportive communities where everyone contributes and benefits equally.",
            },
            {
                "title": "Fairness",
                "body": "Time-based exchange ensures everyone's contribution is valued equally, regardless of the skill.",
            },
            {
                "title": "Quality Learning",
                "body": "We ensure high-quality exchanges through our rating system and community guidelines.",
            },
            {
                "title": "Accessibility",
                "body": "Knowledge should be accessible to everyone, without financial barriers standing in the way.",
            },
            {
                "title": "Growth",
                "body": "We encourage continuous learning and personal development for all community members.",
            },
            {
                "title": "Time Respect",
                "body": "We value everyone's time equally and ensure smooth, respectful exchanges.",
            },
        ],
        "storyTitle": "Our Story",
        "storyParagraphs": [
            "Tiempos started in 2024 when a group of educators and developers came together with a shared vision: to create a world where learning is accessible to everyone, regardless of their financial situation.",
            "We noticed that traditional educational platforms often exclude talented individuals who want to learn but can't afford the fees. Meanwhile, many skilled people want to share their knowledge but don't know where to start.",
            "By using time as currency, we've created a truly equitable platform. Whether you're teaching advanced programming or beginner cooking, your hour is worth the same. This fundamental principle has helped us build a diverse, engaged community of learners and teachers from all walks of life.",
            "Today, Tiempos continues to grow, connecting thousands of people around the world, fostering meaningful connections, and proving that the best things in life – like knowledge and community – don't need a price tag.",
        ],
        "ctaTitle": "Ready to Join Our Community?",
        "ctaSubtitle": "Start sharing your skills and learning from others today. It's free, fair, and fun!",
        "ctaButton": "Get Started",
    },
    "faqPage": {
        "heroTitle": "Frequently Asked Questions",
        "heroSubtitle": "Find answers to common questions about Tiempos",
        "searchPlaceholder": "Search questions…",
        "emptyText": "No questions found matching your search.",
        "ctaTitle": "Still have questions?",
        "ctaText": "Can't find the answer you're looking for? Our support team is here to help.",
        "ctaButton": "Contact us",
        "categories": [
            {"id": "all", "label": "All Questions"},
            {"id": "general", "label": "General"},
            {"id": "getting-started", "label": "Getting Started"},
            {"id": "sessions", "label": "Sessions"},
            {"id": "credits", "label": "Time Credits"},
            {"id": "safety", "label": "Safety"},
            {"id": "technical", "label": "Technical"},
        ],
        "items": [
            {"id": 1, "category": "general", "q": "What is Tiempos?", "a": "Tiempos is a skill exchange platform where users trade skills using time as currency. Instead of paying money, you exchange hours of teaching for hours of learning."},
            {"id": 2, "category": "general", "q": "How does the time credit system work?", "a": "Every new user starts with 1 free hour of time credit. When you teach someone for 1 hour, you earn 1 credit. When you learn from someone for 1 hour, you spend 1 credit. All skills are valued equally in terms of time."},
            {"id": 3, "category": "general", "q": "Is Tiempos free to use?", "a": "Yes! Tiempos is completely free. We believe knowledge should be accessible to everyone. You only “pay” with your time by teaching others."},
            {"id": 4, "category": "getting-started", "q": "How do I get started?", "a": "Simply sign up for a free account, complete your profile, add the skills you can teach, and browse available skills you'd like to learn. You'll start with 1 free hour of time credit to book your first session."},
            {"id": 5, "category": "getting-started", "q": "What skills can I teach or learn?", "a": "Almost anything! From programming and design to cooking and music. If it's a skill that can be taught in a session, you can share it on Tiempos."},
            {"id": 6, "category": "getting-started", "q": "How do I add a new skill?", "a": "Go to your Dashboard and click “Add Skill”. Fill in the details about what you're offering, set your availability, and publish it. Your skill will be visible to other users immediately."},
            {"id": 7, "category": "sessions", "q": "How do sessions work?", "a": "Once you book a session, you'll receive the teacher's contact information. You can meet online (via video call) or in-person if both parties agree. After the session, both users confirm completion and leave ratings."},
            {"id": 8, "category": "sessions", "q": "What happens if I can't attend a scheduled session?", "a": "You can cancel up to 24 hours before the session without penalty. Your time credits will be refunded. Late cancellations may result in credit deduction."},
            {"id": 9, "category": "sessions", "q": "How long are sessions?", "a": "Most sessions are 1 hour, but you can book multiple hours for more in-depth learning. The duration is agreed upon when booking."},
            {"id": 10, "category": "credits", "q": "What if I run out of time credits?", "a": "You can earn more credits by teaching others! Each hour you teach earns you 1 credit that you can use to learn something new."},
            {"id": 11, "category": "credits", "q": "Can I buy time credits?", "a": "No, time credits cannot be purchased. This ensures fairness and maintains the community spirit of equal exchange. You earn credits by contributing your skills."},
            {"id": 12, "category": "credits", "q": "Do time credits expire?", "a": "No! Your time credits never expire. You can save them up and use them whenever you're ready to learn something new."},
            {"id": 13, "category": "safety", "q": "Is Tiempos safe?", "a": "Yes! We verify all users, maintain a rating system, and have community guidelines. We recommend meeting online for your first few sessions and always meeting in public places for in-person sessions."},
            {"id": 14, "category": "safety", "q": "What if I have a problem with another user?", "a": "You can report any issues through our support system. We take all reports seriously and will investigate accordingly. Serious violations may result in account suspension."},
            {"id": 15, "category": "technical", "q": "Can I use Tiempos on mobile?", "a": "Yes! Tiempos is fully responsive and works great on mobile devices. We're also working on dedicated mobile apps for iOS and Android."},
            {"id": 16, "category": "technical", "q": "I forgot my password. What should I do?", "a": "Click “Forgot Password” on the login page. We'll send you a reset link to your email address. Make sure to check your spam folder if you don't see it."},
        ],
    },
    "community": {
        "title": "Community",
        "body": "You are the community. Every published skill, every completed session, and every review strengthens the network.\n\nBe respectful, show up on time, and communicate clearly. Report problems through Support so we can help. Together we keep the exchange fair and welcoming.",
    },
    "contact": {
        "heroTitle": "Get in Touch",
        "heroSubtitle": "Have questions? We'd love to hear from you. Send us a message and we'll respond as soon as possible.",
        "infoTitle": "Contact Information",
        "infoIntro": "Reach us by email — we're here to help.",
        "emailTitle": "Email",
        "emailAddress": "tiempos.site@gmail.com",
        "responseTitle": "Response Time",
        "responseText": "We typically respond within 24 hours on business days.",
        "formTitle": "Send us a Message",
        "labelName": "Full Name",
        "labelEmail": "Email Address",
        "labelSubject": "Subject",
        "labelMessage": "Message",
        "placeholderName": "John Doe",
        "placeholderEmail": "john@example.com",
        "placeholderMessage": "Tell us how we can help you…",
        "subjectPlaceholder": "Select a subject",
        "subjectGeneral": "General inquiry",
        "subjectSupport": "Technical support",
        "subjectBilling": "Billing question",
        "subjectPartnership": "Partnership",
        "subjectFeedback": "Feedback",
        "subjectOther": "Other",
        "sendButton": "Send Message",
        "sending": "Sending…",
        "successTitle": "Message sent!",
        "successText": "Thank you for contacting us. We'll get back to you soon.",
        "errorSend": "Your message could not be sent. Please try again or email us directly.",
        "errorSendAuth": "The server blocked this request (not an account sign-in issue). If you deploy the frontend yourself, set VITE_API_BASE_URL to the API host only (no /api suffix) or configure your host to forward /api to the backend. You can still email us below.",
        "errorSendNotFound": "The contact endpoint was not found (404). Rebuild the static site with VITE_API_BASE_URL pointing to your Spring API, or open the site from a host that forwards /api to the backend. You can still email us below.",
        "errorUnavailable": "Email could not be sent (generic). Check SMTP on the Render API service or write to tiempos.site@gmail.com.",
        "errorSmtpNotReady": "Outbound email (SMTP) is not set up on the server. On the Render API service, set SPRING_MAIL_HOST (e.g. smtp-relay.brevo.com), SPRING_MAIL_PORT=587, SPRING_MAIL_USERNAME and SPRING_MAIL_PASSWORD (from Brevo Transactional → SMTP, not the API key), STARTTLS/auth properties, and APP_MAIL_FROM with a sender verified in Brevo. Alternatively add only BREVO_API_KEY (Brevo → API keys, HTTPS) so the contact form works without SMTP. You can still email tiempos.site@gmail.com.",
        "errorSmtpSendFailed": "SMTP connected but sending failed or was rejected. In Brevo: verify the sender used in APP_MAIL_FROM, use the SMTP password (xsmtpsib-…), and match SPRING_MAIL_USERNAME to the value shown in Brevo’s SMTP screen. See Render API logs for the exact error. You can still email tiempos.site@gmail.com.",
        "faqSectionTitle": "Looking for quick answers?",
        "faqSectionText": "Visit our FAQ page for answers to common questions.",
        "faqButton": "Visit FAQ",
    },
    "support": {
        "title": "Support & help",
        "body": "Need help? Check How it works, Cancellation & no-show policy, and the Instructor guide first. If you are stuck, email support@tiempos.local with your account email and a short description.\n\nWe cannot mediate every dispute, but we take abuse and no-show patterns seriously and may restrict accounts to protect the community.",
    },
    "terms": {
        "title": "Terms of Service",
        "heroSubtitle": "The rules for using Tiempos fairly and safely—profiles, behavior, and time credits.",
        "body": "By creating an account and using Tiempos, you agree to use the service in good faith. You will provide accurate profile information, treat other members with respect, and follow applicable laws.\n\nTime credits are not legal tender, have no cash value, and cannot be redeemed for cash. They exist only to schedule and record skill exchanges inside the platform.\n\nWe may change or discontinue features, send notices in the app, and suspend or restrict accounts that abuse the platform, harass others, or repeatedly break these expectations.\n\nIf we update these terms, we will give reasonable notice where practical. Continued use after changes means you accept the updated terms.\n\nThis page is a plain-language summary for the project. Before a public launch, a complete Terms of Service should be drafted and reviewed with qualified legal counsel.",
    },
    "privacy": {
        "title": "Privacy Policy",
        "heroSubtitle": "How we use account and profile data, what others can see, and how we protect your information.",
        "body": "Tiempos processes personal data that you provide and that is generated when you use the product—for example: account and login details, profile fields you choose to add, messages and notifications related to bookings, and technical data needed to keep the service secure and reliable.\n\nVisibility: Other signed-in members may see the profile information you choose to publish, according to what each screen and your settings describe (for example public profile fields and skill listings). We do not sell your personal information to third parties as a business model.\n\nCookies and security: We use cookies or similar technologies where needed for authentication, preferences, and security (such as keeping you signed in safely). Use a strong, unique password and do not share your login with others.\n\nRetention and deletion: You may request deletion of your account. Some information may be retained where the law, fraud prevention, or serious safety investigations require it.\n\nThis summary supports trust and transparency during development. A full, jurisdiction-specific privacy policy and data-processing agreements should be finalized before production.",
    },
    "policyCancellation": {
        "title": "Cancellations & no-show",
        "heroSubtitle": "When you can cancel a session, what “late cancel” and no-show mean, and how time credits move.",
        "body": "Time credits on Tiempos are settled when the instructor marks a session as completed in the product flow. Until then, making or holding a booking does not permanently debit your balance in the same way as a final charge—see in-app help for the exact behavior in your build.\n\nUse this policy as a shared expectation between members:\n\n— More than 2 hours before the scheduled start: cancellation is typically free of credit movement (in most cases nothing has been finally debited yet; confirm in the app).\n\n— Between 1 and 2 hours before the start: treat this as a late cancellation. Tell the other person as soon as possible. Repeated patterns can affect trust signals and community standing.\n\n— Less than 1 hour before the start, or if someone does not show up (no-show): the session may be forfeited; the host may document the situation through Support. Repeated no-shows may lead to account review.\n\nOptional attendance acknowledgment in a thread can help both sides, but it does not replace the instructor’s “complete session” step for moving credits.\n\nThis is a community guideline, not a substitute for legal advice. Adjust time windows in your deployment if needed.",
    },
    "instructorGuide": {
        "title": "Instructor: approval & session flow",
        "body": "1) A learner sends a request with a proposed time. You can Accept, Decline, or Decline and propose a new time (after a decline).\n\n2) After you Accept, the thread opens fully. Add the meeting link (Zoom, Meet, etc.) in the session card so the learner can join. Conflicting accepted sessions are blocked to protect your calendar.\n\n3) When the real session is done, use “Mark session complete” so time credits are transferred. If something goes wrong, cancel before the scheduled start (rules above).\n\n4) Optional: the learner can mark attendance; it does not replace your completion action but helps trust.",
    },
}

# Turkish — frontend tr.ts + faq-page-tr.ts
TR = json.loads(json.dumps(EN))  # deep copy then patch heavy sections
TR["howItWorks"] = {
    "heroTitle": "Tiempos nasıl çalışır",
    "heroSubtitle": "Beceri takası ve topluluk oluşturmak için basit ve adil bir yol",
    "getStartedFree": "Ücretsiz başla",
    "stepsTitle": "Dört basit adım",
    "stepsSubtitle": "Dakikalar içinde öğrenmeye başlayın",
    "steps": [
        {"number": "01", "title": "Profilini oluştur", "description": "Kayıt ol, becerilerini ve öğrenmek istediklerini anlat. Başlamak sadece 2 dakika sürer."},
        {"number": "02", "title": "Göz at ve bağlan", "description": "Topluluğumuzun sunduğu yüzlerce beceriyi keşfet. İlgi alanlarına ve takvimine göre eşleş."},
        {"number": "03", "title": "Beceri takası yap", "description": "Bildiğini öğret, öğrenmek istediğini öğren. Her öğrettiğin saat zaman kredisi kazandırır."},
        {"number": "04", "title": "Birlikte büyü", "description": "Profilini geliştir ve yaşam boyu öğrenenler topluluğunun parçası ol."},
    ],
    "creditsTitle": "Zaman kredilerini anlamak",
    "creditsIntro": "Zaman kredileri Tiempos'un para birimidir. Sistem son derece basit:",
    "teachHour": "1 saat öğretim = 1 zaman kredisi",
    "teachHourSub": "Bilgini paylaşarak kredi kazan",
    "learnHour": "1 zaman kredisi = 1 saat öğrenme",
    "learnHourSub": "Kredileri herhangi bir şey öğrenmek için harca",
    "bonusTitle": "Yeni üye bonusu",
    "bonusCredits": "1 ücretsiz zaman kredisi",
    "bonusDesc": "Yeni üyeler 1 zaman kredisiyle (1 saat öğrenme) başlar. Hemen başla — önce öğretmen olmana gerek yok.",
    "claimBonus": "Bonusunu al",
    "whyTitle": "Neden Tiempos?",
    "benefits": [
        "Para gerekmez — zamanı zamana takas et",
        "Topluluğundaki tutkulu uzmanlardan öğren",
        "Esnek program — kendi hızında öğren",
        "Anlamlı bağlar kur",
        "Güvenli ve doğrulanmış üyeler",
        "Öğrenme ilerlemeni takip et",
    ],
    "faqTitle": "Sıkça sorulan sorular",
    "miniFaqs": [
        {"q": "Zaman kredileri nasıl işler?", "a": "Her öğrettiğin saat için bir zaman kredisi kazanırsın. Bu kredileri başkalarından öğrenmek için harcarsın. Adil ve eşit bir takas sistemidir."},
        {"q": "Öğretecek becerim yoksa?", "a": "Herkesin paylaşacak bir şeyi vardır! Yemek, bahçecilik, konuştuğun bir dil veya mesleki uzmanlık — Tiempos'ta tüm beceriler değerlidir."},
        {"q": "Hem öğrenip hem öğretebilir miyim?", "a": "Kesinlikle! Üyelerimizin çoğu hem öğretmen hem öğrenci. Öğretirken aynı anda yeni şeyler öğrenebilirsin."},
        {"q": "Tiempos ücretsiz mi?", "a": "Evet! Hesap oluşturmak ve beceri takası tamamen ücretsiz. Öğrenmeyi herkes için erişilebilir kılmayı hedefliyoruz."},
        {"q": "İlk zaman kredilerimi nasıl alırım?", "a": "Yeni üyeler hemen öğrenmeye başlamak için 1 saatlik ücretsiz zaman kredisi alır. Daha fazla kredi için hemen öğretmeye de başlayabilirsin."},
    ],
    "ctaTitle": "Öğrenmeye hazır mısın?",
    "ctaSubtitle": "Topluluğumuzdaki binlerce öğrenci ve öğretmene katıl",
    "ctaButton": "Ücretsiz hesap oluştur",
}
TR["about"] = {
    "heroTitle": "Tiempos hakkında",
    "heroSubtitle": "Zamanın para birimi, becerilerin özgürce paylaşıldığı bir topluluk kuruyoruz",
    "missionTitle": "Misyonumuz",
    "missionP1": "Tiempos güçlü ama basit bir fikirden doğdu: herkesin öğretebileceği bir şey ve öğrenmek istediği bir şey var. Bilginin maddi engellerin arkasında kilitli olmaması gerektiğine inanıyoruz.",
    "missionP2": "Platformumuzda beceriler zaman para birimiyle takas edilir. Bir saat öğretmenlik, başka birinden bir saat öğrenmeye eşittir. Adil, sade ve gerçek bağlar kurar.",
    "statMembers": "Doğrulanmış üyeler",
    "statSkills": "Yayınlanan beceriler",
    "statHours": "Takas edilen saat (tamamlanan)",
    "statSatisfaction": "Memnuniyet (değerlendirmeler)",
    "valuesTitle": "Değerlerimiz",
    "values": [
        {"title": "Önce topluluk", "body": "Herkesin katkıda bulunduğu ve eşit şekilde fayda gördüğü güçlü, destekleyici topluluklar kurarız."},
        {"title": "Adalet", "body": "Zaman tabanlı takas, beceri ne olursa olsun herkesin katkısının eşit değer görmesini sağlar."},
        {"title": "Kaliteli öğrenme", "body": "Değerlendirme sistemimiz ve topluluk kurallarımızla kaliteli takasları destekleriz."},
        {"title": "Erişilebilirlik", "body": "Bilgi, önünde maddi engeller olmadan herkese açık olmalıdır."},
        {"title": "Gelişim", "body": "Tüm üyeler için sürekli öğrenmeyi ve kişisel gelişimi teşvik ederiz."},
        {"title": "Zamana saygı", "body": "Herkesin zamanına eşit değer verir, saygılı ve sorunsuz takaslar hedefleriz."},
    ],
    "storyTitle": "Hikayemiz",
    "storyParagraphs": [
        "Tiempos, 2024'te eğitimciler ve geliştiricilerin ortak bir vizyonla bir araya gelmesiyle başladı: öğrenmenin maddi durumdan bağımsız olarak herkese erişilebilir olduğu bir dünya.",
        "Geleneksel eğitim platformlarının, öğrenmek isteyen ama ücreti karşılayamayan insanları dışarıda bıraktığını gördük. Öte yandan birçok yetenekli insan bilgisini paylaşmak istiyor ama nereden başlayacağını bilmiyor.",
        "Zamanı para birimi olarak kullanarak gerçekten eşitlikçi bir platform oluşturduk. İster ileri düzey programlama ister başlangıç seviyesi yemek pişirme öğretin—saatiniz aynı değerde. Bu ilke, hayatın her alanından öğrenci ve eğitmenlerden oluşan çeşitli ve aktif bir topluluk kurmamıza yardımcı oldu.",
        "Bugün Tiempos büyümeye devam ediyor; dünya çapında binlerce insanı bir araya getiriyor, anlamlı bağlar kuruyor ve bilgi ile topluluk gibi hayattaki en iyi şeylerin etiket gerektirmediğini gösteriyor.",
    ],
    "ctaTitle": "Topluluğumuza katılmaya hazır mısınız?",
    "ctaSubtitle": "Becerilerinizi paylaşın, başkalarından öğrenin. Ücretsiz, adil ve keyifli!",
    "ctaButton": "Başlayın",
}
TR["faqPage"] = {
    "heroTitle": "Sıkça sorulan sorular",
    "heroSubtitle": "Tiempos hakkında merak edilenlere hızlı yanıtlar",
    "searchPlaceholder": "Sorularda ara…",
    "emptyText": "Aramanızla eşleşen soru bulunamadı.",
    "ctaTitle": "Hâlâ sorunuz mu var?",
    "ctaText": "Aradığınız yanıtı bulamadınız mı? Destek ekibimiz size yardımcı olmak için burada.",
    "ctaButton": "İletişime geçin",
    "categories": [
        {"id": "all", "label": "Tüm sorular"},
        {"id": "general", "label": "Genel"},
        {"id": "getting-started", "label": "Başlangıç"},
        {"id": "sessions", "label": "Oturumlar"},
        {"id": "credits", "label": "Zaman kredileri"},
        {"id": "safety", "label": "Güvenlik"},
        {"id": "technical", "label": "Teknik"},
    ],
    "items": [
        {"id": 1, "category": "general", "q": "Tiempos nedir?", "a": "Tiempos, kullanıcıların becerileri zaman para birimiyle takas ettiği bir platformdur. Para ödemek yerine öğretme saatlerinizi öğrenme saatleriyle değiştirirsiniz."},
        {"id": 2, "category": "general", "q": "Zaman kredisi sistemi nasıl işler?", "a": "Her yeni kullanıcı 1 saatlik ücretsiz zaman kredisi ile başlar. Birine 1 saat öğrettiğinizde 1 kredi kazanırsınız; birinden 1 saat öğrendiğinizde 1 kredi harcarsınız. Tüm beceriler süre açısından eşit değerlendirilir."},
        {"id": 3, "category": "general", "q": "Tiempos ücretsiz mi?", "a": "Evet! Tiempos tamamen ücretsizdir. Bilginin herkese açık olması gerektiğine inanıyoruz. Ödeme yalnızca başkalarına öğreterek zamanınızla yapılır."},
        {"id": 4, "category": "getting-started", "q": "Nasıl başlarım?", "a": "Ücretsiz hesap oluşturun, profilinizi tamamlayın, öğretebileceğiniz becerileri ekleyin ve öğrenmek istediğiniz becerilere göz atın. İlk oturumunuzu ayırmak için 1 saatlik ücretsiz zaman kredisi ile başlarsınız."},
        {"id": 5, "category": "getting-started", "q": "Hangi becerileri öğretebilir veya öğrenebilirim?", "a": "Neredeyse her şey! Programlama ve tasarımdan yemek ve müziğe kadar. Bir oturumda öğretilebilecek bir beceri ise Tiempos'ta paylaşabilirsiniz."},
        {"id": 6, "category": "getting-started", "q": "Yeni beceri nasıl eklerim?", "a": "Kontrol panelinize gidin ve “Beceri ekle”ye tıklayın. Sunduğunuz içeriği, müsaitliğinizi doldurun ve yayınlayın. Beceriniz diğer kullanıcılara hemen görünür."},
        {"id": 7, "category": "sessions", "q": "Oturumlar nasıl işler?", "a": "Bir oturum ayırdığınızda eğitmenin iletişim bilgilerini alırsınız. İki taraf da kabul ederse çevrim içi (görüntülü görüşme) veya yüz yüze buluşabilirsiniz. Oturumdan sonra her iki taraf tamamlamayı onaylar ve değerlendirme bırakır."},
        {"id": 8, "category": "sessions", "q": "Planlanmış bir oturuma katılamazsam ne olur?", "a": "Oturumdan en az 24 saat önce cezasız iptal edebilirsiniz; zaman kredileriniz iade edilir. Geç iptallerde kredi kesintisi olabilir."},
        {"id": 9, "category": "sessions", "q": "Oturumlar ne kadar sürer?", "a": "Çoğu oturum 1 saattir; daha derinlemesine öğrenmek için birden fazla saat ayırabilirsiniz. Süre rezervasyon sırasında kararlaştırılır."},
        {"id": 10, "category": "credits", "q": "Zaman kredim biterse ne yaparım?", "a": "Başkalarına öğreterek daha fazla kredi kazanabilirsiniz! Öğrettiğiniz her saat için 1 kredi kazanıp yeni şeyler öğrenmek için kullanabilirsiniz."},
        {"id": 11, "category": "credits", "q": "Zaman kredisi satın alabilir miyim?", "a": "Hayır; zaman kredisi satın alınamaz. Bu, adilliği ve eşit takası korur. Kredileri yalnızca beceri katkınızla kazanırsınız."},
        {"id": 12, "category": "credits", "q": "Zaman kredilerinin süresi doluyor mu?", "a": "Hayır! Kredilerinizin süresi dolmaz. İstediğiniz zaman biriktirip yeni bir şey öğrenmeye hazır olduğunuzda kullanırsınız."},
        {"id": 13, "category": "safety", "q": "Tiempos güvenli mi?", "a": "Evet! Kullanıcıları doğrular, değerlendirme sistemi ve topluluk kurallarımız vardır. İlk oturumlar için çevrim içi buluşmayı; yüz yüze için ise kalabalık yerleri öneririz."},
        {"id": 14, "category": "safety", "q": "Başka bir kullanıcıyla sorun yaşarsam ne yapmalıyım?", "a": "Sorunları destek sistemimiz üzerinden bildirebilirsiniz. Tüm bildirimleri ciddiye alır ve inceleriz. Ağır ihlaller hesap askıya alınmasına yol açabilir."},
        {"id": 15, "category": "technical", "q": "Tiempos'u mobilde kullanabilir miyim?", "a": "Evet! Tiempos duyarlıdır ve mobilde iyi çalışır. iOS ve Android için özel uygulamalar üzerinde de çalışıyoruz."},
        {"id": 16, "category": "technical", "q": "Şifremi unuttum, ne yapmalıyım?", "a": "Giriş sayfasında “Şifremi unuttum”a tıklayın. E-posta adresinize sıfırlama bağlantısı göndeririz. Görünmezse spam klasörünü kontrol edin."},
    ],
}
TR["community"] = {
    "title": "Topluluk",
    "body": "Topluluk, sizsiniz. Her yayınlanan beceri, tamamlanan oturum ve değerlendirme ağı güçlendirir.\n\nSaygılı olun, saatinde bulunun, net iletişim kurun. Sorunları Destek üzerinden bildirin. Birlikte takası adil ve güvenli tutarız.",
}
TR["contact"] = {
    "heroTitle": "İletişime geçin",
    "heroSubtitle": "Sorularınız mı var? Mesajınızı bekliyoruz; en kısa sürede yanıtlıyoruz.",
    "infoTitle": "İletişim bilgileri",
    "infoIntro": "Bize e-posta ile ulaşabilirsiniz; yardımcı olmaktan memnuniyet duyarız.",
    "emailTitle": "E-posta",
    "emailAddress": "tiempos.site@gmail.com",
    "responseTitle": "Yanıt süresi",
    "responseText": "İş günlerinde genelde 24 saat içinde e-posta ile döneriz.",
    "formTitle": "Bize yazın",
    "labelName": "Ad Soyad",
    "labelEmail": "E-posta",
    "labelSubject": "Konu",
    "labelMessage": "Mesaj",
    "placeholderName": "Ad Soyad",
    "placeholderEmail": "ornek@email.com",
    "placeholderMessage": "Nasıl yardımcı olabileceğimizi yazın…",
    "subjectPlaceholder": "Konu seçin",
    "subjectGeneral": "Genel bilgi",
    "subjectSupport": "Teknik destek",
    "subjectBilling": "Fatura / ödeme",
    "subjectPartnership": "İş birliği",
    "subjectFeedback": "Geri bildirim",
    "subjectOther": "Diğer",
    "sendButton": "Mesajı gönder",
    "sending": "Gönderiliyor…",
    "successTitle": "Mesajınız iletildi!",
    "successText": "İletişime geçtiğiniz için teşekkürler. En kısa sürede size döneceğiz.",
    "errorSend": "Mesaj gönderilemedi. Lütfen tekrar deneyin veya doğrudan e-posta yazın.",
    "errorSendAuth": "Sunucu isteği reddetti (hesap girişi ile ilgili değil). Frontend’i kendiniz barındırıyorsanız VITE_API_BASE_URL yalnızca API ana makinesi olmalı (sonunda /api olmamalı) veya barındırıcıda /api trafiğinin backend’e yönlendirildiğinden emin olun. Yine de aşağıdaki e-posta adresine yazabilirsiniz.",
    "errorSendNotFound": "İletişim adresi bulunamadı (404). Statik siteyi VITE_API_BASE_URL Spring API kökünü gösterecek şekilde yeniden derleyin veya /api trafiğini backend’e yönlendiren bir adres kullanın. Yine de aşağıdaki e-postaya yazabilirsiniz.",
    "errorUnavailable": "E-posta gönderilemedi (genel). Render API servisindeki SMTP ayarlarını veya aşağıdaki adresi kullanın.",
    "errorSmtpNotReady": "Sunucuda giden posta (SMTP) yapılandırması eksik. Render’da API servisine ekleyin: SPRING_MAIL_HOST (ör. smtp-relay.brevo.com), SPRING_MAIL_PORT=587, SPRING_MAIL_USERNAME ve SPRING_MAIL_PASSWORD (Brevo Transactional → SMTP’deki giriş; API key değil), STARTTLS/auth property’leri ve Brevo’da doğrulanmış bir APP_MAIL_FROM. Alternatif: yalnızca BREVO_API_KEY (Brevo → API keys, HTTPS) ekleyerek iletişim formunu SMTP olmadan çalıştırabilirsiniz. Yine de tiempos.site@gmail.com adresine yazabilirsiniz.",
    "errorSmtpSendFailed": "SMTP bağlantısı kuruldu ama gönderim reddedildi veya hata verdi. Brevo’da APP_MAIL_FROM ile aynı göndericiyi doğrulayın; şifre olarak SMTP anahtarını (xsmtpsib-...) kullanın; kullanıcı adını Brevo SMTP ekranındakiyle birebir aynı yapın. Ayrıntı için Render API loglarına bakın. Yine de tiempos.site@gmail.com adresine yazabilirsiniz.",
    "faqSectionTitle": "Hızlı cevaplar mı arıyorsunuz?",
    "faqSectionText": "Yaygın soruların yanıtları için SSS sayfamıza göz atın.",
    "faqButton": "SSS’ye git",
}
TR["support"] = {
    "title": "Destek ve yardım",
    "body": "Yardıma mı ihtiyacınız var? Önce Nasıl çalışır, İptal ve no-show politikası ve Eğitmen rehberi sayfalarına bakın. Takıldıysanız support@tiempos.local adresine hesap e-postanızı ve kısa açıklamayı yazın.\n\nHer anlaşmazlığa arabuluculuk yapamayız; ancak kötüye kullanım ve tekrarlayan no-show modellerini ciddiye alır, topluluğu korumak için hesap kısıtlayabiliriz.",
}
TR["terms"] = {
    "title": "Kullanım şartları",
    "heroSubtitle": "Tiempos'u adil ve güvenli kullanma kuralları: profil, davranış ve zaman kredileri.",
        "body": "Tiempos'ta hesap oluşturup hizmeti kullanarak, platformu iyi niyetle kullanmayı kabul edersiniz. Profil bilgilerinizi doğru tutar, diğer üyelere saygılı davranır ve yürürlükteki yasalara uyarsınız.\n\nZaman kredileri yasal para değildir, nakde çevrilemez ve nakit değeri yoktur; yalnızca uygulama içinde beceri takası ve oturum akışını düzenlemek içindir.\n\nÖzellikleri değiştirebilir, kötüye kullanım, taciz veya tekrarlayan ihlallerde hesapları askıya alabilir veya kısıtlayabilir, gerekli durumlarda uygulama içi bildirimlerle haber verebiliriz.\n\nŞartları güncellersek makul ölçüde bildirim yapılır; güncellemeden sonra kullanımı sürdürmek güncel şartları kabul sayılır.\n\nBu metin geliştirme amaçlı sade bir özettir. Canlıya çıkmadan önce tam hukuki metin uzman avukatla hazırlanmalıdır.",
}
TR["privacy"] = {
    "title": "Gizlilik politikası",
    "heroSubtitle": "Hesap ve profil verilerinin kullanımı, görünürlük ve güvenlik hakkında özet bilgi.",
    "body": "Tiempos; hesap ve oturum bilgilerinizi, eklediğiniz profil alanlarını, rezervasyon ve mesajlaşma ile bildirim süreçlerinde oluşan verileri ve hizmeti güvenli çalıştırmak için gerekli teknik kayıtları işleyebilir.\n\nGörünürlük: Yayınladığınız profil bilgileri, her ekranda ve ayarlarınızda belirtildiği şekilde diğer oturum açmış üyelere gösterilebilir. Kişisel verilerinizi üçüncü taraflara “satmak” iş modelimiz değildir.\n\nÇerezler ve güvenlik: Oturum açma, tercihler ve güvenlik için gerekli olduğu ölçüde çerez veya benzeri teknolojiler kullanılabilir. Güçlü ve benzersiz bir şifre kullanın; hesap bilgilerinizi paylaşmayın.\n\nSaklama ve silme: Hesap silme talebinde bulunabilirsiniz. Yasal zorunluluk, ciddi güvenlik veya dolandırıcılık önleme için bazı kayıtların tutulması gerekebilir.\n\nBu özet, geliştirme aşamasında şeffaflık içindir. Canlı ortam için ülkeye özgü tam gizlilik politikası ve veri işleme düzenlemeleri yayımlanmalıdır.",
}
TR["policyCancellation"] = {
    "title": "İptal, geç iptal ve no-show",
    "heroSubtitle": "Oturumu ne zaman iptal edebileceğiniz, geç iptal ve gelmeme durumunda beklentiler ve kredi mantığı.",
    "body": "Zaman kredileri genelde eğitmen oturumu ürün içinde “tamamlandı” olarak işaretlendiğinde kesinleşir. Yalnızca rezervasyon veya bekleme durumunda bakiyenizin nasıl etkilendiğini uygulama içi yardımdan doğrulayın.\n\nÜyeler arasında ortak beklenti olarak şunları kullanabilirsiniz:\n\n— Planlanan başlangıçtan 2 saatten fazla önce: iptal tipik olarak kredi hareketi olmadan yapılabilir (çoğu senaryoda kesin borç henüz oluşmamıştır; uygulamayı kontrol edin).\n\n— Başlangıçtan 1–2 saat önce: geç iptal sayılır; karşı tarafı derhal bilgilendirin. Tekrarlayan örüntüler güven ve topluluk güvenilirliğini etkileyebilir.\n\n— 1 saatten az kala veya hiç gelinmemesi (no-show): oturum düşebilir; eğitmen durumu Destek üzerinden kayda geçirebilir. Tekrarlayan no-show hesap incelemesine yol açabilir.\n\nİş parçacığındaki isteğe bağlı “katılım” bilgisi iki tarafa yardımcı olur; kredi aktarımını belirleyen adım yine eğitmenin tamamlama işlemidir.\n\nBu metin topluluk yönergesidir, hukuki danışmanlık yerine geçmez. Eşik sürelerini kurulumunuza göre güncelleyebilirsiniz.",
}
TR["instructorGuide"] = {
    "title": "Eğitmen: onay ve oturum akışı",
    "body": "1) Öğrenci talep + zaman önerir. Siz kabul, red veya red + yeni zaman teklif edebilirsiniz (red sonrası).\n\n2) Kabulden sonra sohbet tam açılır. Takvimde çakışan onaylı oturum engellenir. Zoom/Meet veya sınıf linkini oturum kartında paylaşın.\n\n3) Gerçek ders bittiğinde “Oturumu tamamlandı işaretle” ile kredi aktarılır. Sorun varsa, başlangıçtan önce iptal (yukarıdaki politika).\n\n4) İsteğe bağlı: öğrenci “katıldım” onayı verebilir; güvence amaçlı—tamamlandı adımının yerine geçmez.",
}


def dart_str(s: str) -> str:
    return json.dumps(s, ensure_ascii=False)


def emit_help_center_bundle(name: str, data: dict) -> str:
    h = data["howItWorks"]
    steps = ",\n    ".join(
        "HowItWorksStep(number: {}, title: {}, description: {})".format(
            dart_str(x["number"]), dart_str(x["title"]), dart_str(x["description"])
        )
        for x in h["steps"]
    )
    benefits = ",\n    ".join(dart_str(x) for x in h["benefits"])
    mini = ",\n    ".join("(q: {}, a: {})".format(dart_str(x["q"]), dart_str(x["a"])) for x in h["miniFaqs"])

    a = data["about"]
    values = ",\n    ".join(
        "AboutValue(title: {}, body: {})".format(dart_str(x["title"]), dart_str(x["body"])) for x in a["values"]
    )
    story = ",\n    ".join(dart_str(x) for x in a["storyParagraphs"])

    fp = data["faqPage"]
    cats = ",\n    ".join(
        "FaqCategory(id: {}, label: {})".format(dart_str(x["id"]), dart_str(x["label"])) for x in fp["categories"]
    )
    items = ",\n    ".join(
        "FaqItem(id: {}, category: {}, q: {}, a: {})".format(
            x["id"], dart_str(x["category"]), dart_str(x["q"]), dart_str(x["a"])
        )
        for x in fp["items"]
    )

    c = data["contact"]

    def static_block(key: str) -> str:
        s = data[key]
        return "StaticTwoField(title: {}, body: {})".format(dart_str(s["title"]), dart_str(s["body"]))

    def legal_block(key: str) -> str:
        s = data[key]
        return "LegalDocCopy(title: {}, heroSubtitle: {}, body: {})".format(
            dart_str(s["title"]), dart_str(s["heroSubtitle"]), dart_str(s["body"])
        )

    ig = data["instructorGuide"]
    instructor = "StaticTwoField(title: {}, body: {})".format(dart_str(ig["title"]), dart_str(ig["body"]))

    out = f'''import 'help_models.dart';

/// Web `en.ts` / `tr.ts` + FAQ locale dosyalarıyla hizalı (otomatik üretildi — `tool/generate_help_bundles.py`).
const HelpCenterBundle {name} = HelpCenterBundle(
  howItWorks: HowItWorksCopy(
    heroTitle: {dart_str(h["heroTitle"])},
    heroSubtitle: {dart_str(h["heroSubtitle"])},
    getStartedFree: {dart_str(h["getStartedFree"])},
    stepsTitle: {dart_str(h["stepsTitle"])},
    stepsSubtitle: {dart_str(h["stepsSubtitle"])},
    steps: <HowItWorksStep>[
    {steps},
    ],
    creditsTitle: {dart_str(h["creditsTitle"])},
    creditsIntro: {dart_str(h["creditsIntro"])},
    teachHour: {dart_str(h["teachHour"])},
    teachHourSub: {dart_str(h["teachHourSub"])},
    learnHour: {dart_str(h["learnHour"])},
    learnHourSub: {dart_str(h["learnHourSub"])},
    bonusTitle: {dart_str(h["bonusTitle"])},
    bonusCredits: {dart_str(h["bonusCredits"])},
    bonusDesc: {dart_str(h["bonusDesc"])},
    claimBonus: {dart_str(h["claimBonus"])},
    whyTitle: {dart_str(h["whyTitle"])},
    benefits: <String>[
    {benefits},
    ],
    faqTitle: {dart_str(h["faqTitle"])},
    miniFaqs: <({{String q, String a}})>[
    {mini},
    ],
    ctaTitle: {dart_str(h["ctaTitle"])},
    ctaSubtitle: {dart_str(h["ctaSubtitle"])},
    ctaButton: {dart_str(h["ctaButton"])},
  ),
  about: AboutCopy(
    heroTitle: {dart_str(a["heroTitle"])},
    heroSubtitle: {dart_str(a["heroSubtitle"])},
    missionTitle: {dart_str(a["missionTitle"])},
    missionP1: {dart_str(a["missionP1"])},
    missionP2: {dart_str(a["missionP2"])},
    statMembers: {dart_str(a["statMembers"])},
    statSkills: {dart_str(a["statSkills"])},
    statHours: {dart_str(a["statHours"])},
    statSatisfaction: {dart_str(a["statSatisfaction"])},
    valuesTitle: {dart_str(a["valuesTitle"])},
    values: <AboutValue>[
    {values},
    ],
    storyTitle: {dart_str(a["storyTitle"])},
    storyParagraphs: <String>[
    {story},
    ],
    ctaTitle: {dart_str(a["ctaTitle"])},
    ctaSubtitle: {dart_str(a["ctaSubtitle"])},
    ctaButton: {dart_str(a["ctaButton"])},
  ),
  faq: FaqPageCopy(
    heroTitle: {dart_str(fp["heroTitle"])},
    heroSubtitle: {dart_str(fp["heroSubtitle"])},
    searchPlaceholder: {dart_str(fp["searchPlaceholder"])},
    emptyText: {dart_str(fp["emptyText"])},
    ctaTitle: {dart_str(fp["ctaTitle"])},
    ctaText: {dart_str(fp["ctaText"])},
    ctaButton: {dart_str(fp["ctaButton"])},
    categories: <FaqCategory>[
    {cats},
    ],
    items: <FaqItem>[
    {items},
    ],
  ),
  community: {static_block("community")},
  contact: ContactPageCopy(
    heroTitle: {dart_str(c["heroTitle"])},
    heroSubtitle: {dart_str(c["heroSubtitle"])},
    infoTitle: {dart_str(c["infoTitle"])},
    infoIntro: {dart_str(c["infoIntro"])},
    emailTitle: {dart_str(c["emailTitle"])},
    emailAddress: {dart_str(c["emailAddress"])},
    responseTitle: {dart_str(c["responseTitle"])},
    responseText: {dart_str(c["responseText"])},
    formTitle: {dart_str(c["formTitle"])},
    labelName: {dart_str(c["labelName"])},
    labelEmail: {dart_str(c["labelEmail"])},
    labelSubject: {dart_str(c["labelSubject"])},
    labelMessage: {dart_str(c["labelMessage"])},
    placeholderName: {dart_str(c["placeholderName"])},
    placeholderEmail: {dart_str(c["placeholderEmail"])},
    placeholderMessage: {dart_str(c["placeholderMessage"])},
    subjectPlaceholder: {dart_str(c["subjectPlaceholder"])},
    subjectGeneral: {dart_str(c["subjectGeneral"])},
    subjectSupport: {dart_str(c["subjectSupport"])},
    subjectBilling: {dart_str(c["subjectBilling"])},
    subjectPartnership: {dart_str(c["subjectPartnership"])},
    subjectFeedback: {dart_str(c["subjectFeedback"])},
    subjectOther: {dart_str(c["subjectOther"])},
    sendButton: {dart_str(c["sendButton"])},
    sending: {dart_str(c["sending"])},
    successTitle: {dart_str(c["successTitle"])},
    successText: {dart_str(c["successText"])},
    errorSend: {dart_str(c["errorSend"])},
    errorSendAuth: {dart_str(c["errorSendAuth"])},
    errorSendNotFound: {dart_str(c["errorSendNotFound"])},
    errorUnavailable: {dart_str(c["errorUnavailable"])},
    errorSmtpNotReady: {dart_str(c["errorSmtpNotReady"])},
    errorSmtpSendFailed: {dart_str(c["errorSmtpSendFailed"])},
    faqSectionTitle: {dart_str(c["faqSectionTitle"])},
    faqSectionText: {dart_str(c["faqSectionText"])},
    faqButton: {dart_str(c["faqButton"])},
  ),
  support: {static_block("support")},
  terms: {legal_block("terms")},
  privacy: {legal_block("privacy")},
  policyCancellation: {legal_block("policyCancellation")},
  instructorGuide: {instructor},
);
'''
    return textwrap.dedent(out)


def main() -> None:
    OUT_EN.write_text(emit_help_center_bundle("kHelpBundleEn", EN), encoding="utf-8")
    OUT_TR.write_text(emit_help_center_bundle("kHelpBundleTr", TR), encoding="utf-8")
    print("Wrote", OUT_EN, "and", OUT_TR)


if __name__ == "__main__":
    main()
