# Grant & Benefits Eligibility Assistant
### Faster, Fairer and Accountable Public Service Decisions

**Team:** Master Chefs  
**Project:** SITA Hackathon 2026  
**Category:** Artificial Intelligence | Government Digital Transformation | Public Service Innovation

---

## 1. Project Overview

The **Grant & Benefits Eligibility Assistant** is an AI-powered decision-support platform designed to help government officials assess applications for grants, bursaries, housing subsidies and other social benefits.

The platform combines Artificial Intelligence (AI), Optical Character Recognition (OCR), Intelligent Document Processing (IDP) and a configurable eligibility rules engine to automate repetitive administrative tasks, validate supporting documentation and generate evidence-based eligibility recommendations.

Instead of manually interpreting policy documents, reviewing supporting evidence and cross-checking application information, government officials can use the platform to streamline assessments, identify inconsistencies and make more informed decisions.

The system recommends one of three outcomes:

- **Likely Eligible:** Available evidence indicates that the applicant satisfies the eligibility requirements.
- **Not Eligible:** Available evidence indicates that one or more eligibility requirements have not been satisfied.
- **Needs Review:** Information is incomplete, inconsistent or insufficient to support a reliable recommendation.

Every recommendation includes a confidence level, an explanation and references to the eligibility rules and supporting evidence.

**Important:** The platform is a decision-support system, not an automated decision-maker. An authorised government official retains responsibility for every final application decision.

---

## 2. Problem Statement

Government departments responsible for administering grants, bursaries, subsidies and social benefits face significant challenges in processing applications efficiently, consistently and transparently.

Current processes often require officials to manually interpret policy documents, examine supporting documentation, verify applicant information and determine whether individuals satisfy programme-specific eligibility requirements.

These processes are time-consuming, resource-intensive and susceptible to human error, inconsistent policy interpretation, fraudulent submissions and administrative backlogs.

Additionally, applicants often receive limited explanations regarding application outcomes, making it difficult to understand eligibility requirements or identify missing documentation.

The challenge is to develop an AI-powered platform that improves application assessment through intelligent document processing, configurable eligibility rules and explainable recommendations while preserving human oversight, fairness and accountability.

---

## 3. The Opportunity

The project presents an opportunity to modernise government benefit administration through a reusable AI-powered eligibility assessment platform.

By combining AI, OCR and configurable business rules, government departments can transition from manual application assessments towards standardised, evidence-based decision-support processes.

Key opportunities include:

1. **Accelerate service delivery:** Reduce the time spent manually reviewing applications and supporting documents.
2. **Reduce administrative backlogs:** Automate repetitive assessment tasks and improve operational efficiency.
3. **Improve decision consistency:** Apply standardised eligibility criteria across applications.
4. **Strengthen fraud prevention:** Identify duplicate applications, suspicious documents and conflicting information.
5. **Promote transparency:** Explain recommendations using specific eligibility rules and supporting evidence.
6. **Improve citizen experience:** Help applicants understand requirements, missing documents and application progress.
7. **Enable data-driven government:** Provide insights into application trends, processing bottlenecks and programme performance.
8. **Support digital transformation:** Establish a reusable platform that SITA can adapt across multiple government departments.

---

## 4. Proposed Solution

We propose a modular Government Eligibility Intelligence Platform that assists government officials throughout the application assessment lifecycle.

### Core workflow

1. **Application Submission**
   - Applicants submit grant, bursary or subsidy applications.
   - Supporting documents are uploaded.
   - Application information is captured and validated.

2. **Intelligent Document Processing**
   - OCR extracts information from uploaded documents.
   - Supported documents include identity documents, payslips, bank statements, academic transcripts and proof of residence.
   - The system checks document completeness and identifies inconsistencies.

3. **Eligibility Rules Engine**
   - Configurable eligibility criteria are applied to application information.
   - Policy rules determine whether applicants satisfy programme-specific requirements.
   - Authorised policy administrators can manage eligibility criteria.

4. **AI-Powered Assessment**
   - Extracted information is evaluated against the configured eligibility rules.
   - The system identifies missing information, discrepancies and potential anomalies.
   - An eligibility recommendation and confidence level are generated.

5. **Explainable Recommendations**
   - Every recommendation includes a plain-language explanation.
   - Applicable eligibility rules are referenced.
   - Supporting evidence is identified.
   - Uncertain cases are escalated for manual assessment.

6. **Human Review and Approval**
   - Officials review recommendations and supporting evidence.
   - Officials can approve, amend or reject applications.
   - Any override must include a recorded reason.

7. **Audit and Reporting**
   - Application assessments and human actions are recorded.
   - Rule versions and recommendation history are retained.
   - Operational dashboards provide application processing insights.

---

## 5. Key Features

| Feature | Description |
|---|---|
| AI Eligibility Assistant | Generates evidence-based eligibility recommendations. |
| Intelligent Document Processing | Extracts information from supporting documents using OCR. |
| Configurable Rules Engine | Applies eligibility policies without requiring code changes for routine policy updates. |
| Document Validation | Identifies missing documents and inconsistent information. |
| Confidence Scoring | Indicates the reliability and completeness of an assessment. |
| Explainable AI | Provides understandable reasons behind recommendations. |
| Human-in-the-Loop | Ensures officials retain final decision-making authority. |
| Audit Trail | Records assessments, rule versions and human actions. |
| Duplicate Detection | Identifies potentially duplicated applications. |
| Policy Q&A Assistant | Helps officials understand programme requirements. |
| Operations Dashboard | Displays application volumes, processing statuses and trends. |
| Citizen Notifications | Communicates application progress and outstanding requirements. |

---

## 6. Technology Stack

The platform is designed around a modular architecture that separates the mobile/web interface, business logic, AI services, document processing and data persistence.

### Frontend
- Flutter
- Dart
- BLoC (Business Logic Component) state management

### Backend and Application Services
- Java / Spring Boot (where applicable)
- RESTful APIs
- Configurable eligibility rules engine

### Database and Storage
- MySQL
- Firebase Authentication (where applicable)
- Firebase Storage (where applicable)

### Artificial Intelligence
- Gemini API or an approved AI model
- OCR / Intelligent Document Processing
- AI-assisted policy interpretation
- Explainable recommendation generation

### Development and Integration
- Git and GitHub
- Maven (for Spring Boot services)
- GitHub Actions
- Postman / Insomnia

*The technology stack may be adjusted according to the hackathon prototype's implementation requirements.*

---

## 7. System Architecture

The solution follows a modular, service-oriented architecture.

```text
                 CITIZEN / GOVERNMENT OFFICIAL
                              |
                              v
                    FLUTTER APPLICATION
                              |
                              v
                         REST API
                              |
             +----------------+----------------+
             |                |                |
             v                v                v
       APPLICATION       DOCUMENT          USER AND
        MANAGEMENT       PROCESSING        ACCESS CONTROL
             |                |                |
             |                v                |
             |             OCR / IDP           |
             |                |                |
             +----------------+----------------+
                              |
                              v
                      ELIGIBILITY ENGINE
                              |
                 +------------+------------+
                 |                         |
                 v                         v
           BUSINESS RULES              AI SERVICES
                 |                         |
                 +------------+------------+
                              |
                              v
                    ASSESSMENT ENGINE
                              |
                              v
                  EXPLAINABLE RECOMMENDATION
                              |
                              v
                    HUMAN REVIEW WORKFLOW
                              |
                    +---------+---------+
                    |                   |
                    v                   v
              FINAL DECISION       AUDIT TRAIL
                    |                   |
                    +---------+---------+
                              |
                              v
                    DATABASE / REPORTING
```

---

## 8. User Roles

### 8.1 Applicant
- Register and access the platform.
- Submit applications.
- Upload supporting documentation.
- View application status.
- Receive notifications about missing documentation.
- View available explanations and application requirements.

### 8.2 Government Official
- View assigned applications.
- Review extracted document information.
- Examine eligibility recommendations.
- Approve, amend or reject applications.
- Record reasons for overrides.
- Access assessment history.

### 8.3 Policy Administrator
- Create and manage benefit programmes.
- Configure eligibility criteria.
- Update policy rules.
- Manage rule versions.
- Review programme assessment performance.

### 8.4 System Administrator
- Manage user roles and permissions.
- Monitor system operations.
- Configure integrations.
- Review system audit records.

---

## 9. Data Collection and Privacy

The hackathon prototype will use synthetic and anonymised application records.

No real personal information or actual citizen application records will be used.

### Proposed synthetic datasets
- Sample social grant applications.
- Sample educational bursary applications.
- Sample housing subsidy applications.
- Synthetic identity documents.
- Synthetic payslips.
- Synthetic bank statements.
- Synthetic academic transcripts.
- Synthetic proof of residence documents.

Mock integrations may be implemented to demonstrate how government identity verification and income verification services could operate.

### Privacy and Security Principles

The platform will be designed around:

- Protection of Personal Information Act (POPIA).
- Data minimisation.
- Purpose limitation.
- Secure document handling.
- Role-based access control.
- Secure authentication and authorisation.
- Controlled access to sensitive application information.
- Audit logging.
- Protection against unauthorised data access.

---

## 10. Fairness, Transparency and Accountability

The platform must support responsible AI implementation in public administration.

The following safeguards will be implemented:

- No application will be automatically declined by AI.
- Every recommendation must be reviewable by an authorised official.
- Low-confidence assessments must be escalated.
- Missing or conflicting information must not be treated as proof of ineligibility.
- Eligibility recommendations must reference the specific rules and evidence used.
- Human overrides must include reasons.
- Sensitive personal attributes and discriminatory proxies must not influence eligibility recommendations.
- Rule changes must be version-controlled.
- Every assessment and decision must be auditable.

The platform aims to support the principles of administrative justice under the Promotion of Administrative Justice Act (PAJA), including the right to procedurally fair administrative action and, where applicable, reasons for decisions.

---

## 11. Expected Impact

| Area | Expected Impact |
|---|---|
| Processing Efficiency | Faster application assessments. |
| Operational Efficiency | Reduced manual administrative workload. |
| Accuracy | Improved consistency in applying eligibility rules. |
| Fraud Prevention | Earlier identification of suspicious information. |
| Transparency | Clear explanations for recommendations. |
| Accountability | Traceable assessments and official decisions. |
| Citizen Experience | Improved access to application information. |
| Scalability | Reusable platform across government programmes. |

These are intended outcomes; measurable improvements will need to be established through testing and evaluation.

---

## 12. Future Enhancements

The platform can be extended with:

- Multilingual AI assistance for South African languages.
- Integration with approved government identity verification services.
- Integration with approved income verification services.
- Advanced duplicate and anomaly detection.
- Automated policy document ingestion and rule extraction.
- Rules-as-a-Service API for other government systems.
- Predictive application workload analytics.
- Advanced fairness monitoring.
- SMS and WhatsApp application status notifications.
- Department-specific dashboards and reporting.

---

## 13. Project Objectives

The primary objective is to demonstrate how AI can improve government service delivery through intelligent application assessment.

The prototype aims to demonstrate:

1. How policy requirements can be represented as machine-readable eligibility rules.
2. How OCR can extract information from supporting documents.
3. How application information can be checked against eligibility criteria.
4. How AI can generate explainable recommendations.
5. How government officials can review and make final decisions.
6. How application assessments can be recorded for accountability.
7. How the platform can be adapted to different government benefit programmes.

---

## 14. Getting Started

### Prerequisites

Install the following development tools:

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Git
- MySQL (if using the relational database implementation)
- Firebase project (if Firebase services are enabled)
- Gemini API key (if Gemini integration is enabled)

### Clone the repository

```bash
git clone <REPOSITORY_URL>
```

Navigate into the project:

```bash
cd <PROJECT_DIRECTORY>
```

### Install dependencies

```bash
flutter pub get
```

### Run the application

```bash
flutter run
```

*Backend services and environment-specific configuration must be started separately if enabled.*

### Environment Configuration

Store credentials and API keys in environment configuration or a secure secrets manager.

Never commit API keys, database passwords, Firebase service-account credentials or other secrets to GitHub.

---

## 15. Hackathon Team

**Team Name:** Master Chefs

**Challenge:** How can Artificial Intelligence transform government services, improve decision-making, make information more accessible and make processes more efficient?

**Proposed Solution:** Grant & Benefits Eligibility Assistant.

---

## 16. Our Vision

To empower government institutions with intelligent technology that makes public services more efficient, accessible, transparent and accountable.

**One platform. Multiple government services. Faster, fairer and more accountable decisions.**

---

*Built by Team Master Chefs for the SITA Hackathon 2026.*
