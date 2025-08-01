# ./ai/README.md

## 🧠 Purpose

This folder provides a minimal, rigorous, and extensible framework for **human–AI collaborative data analysis**, where the human serves as **philosopher–scientist** and the AI functions as a **modal translator and analytic executor**.

## 📂 ./ai/ Core Files

| File | Function |
|------|----------|
| `mission.md` | Declares purpose and impact goals |
| `glossary.md` | Defines key terms and constructs |
| `method.md` | Articulates valid methods and inference rules |
| `semiology.md` | Maps how meaning is expressed across dialects |
| `onboarding-ai.md` | Guides how AI should behave and support the human |
| `logbook.md` | Captures all major analytic decisions over time |
| `FIDES.md` | Validation tests and epistemic safeguards |
| **🆕 `CACHE-manifest.md`** | **Automatically maintained documentation of all processed datasets** |
| `CACHE-manifest-example.md` | Template for CACHE manifest structure |

## 🆕 Automated Documentation System

The **CACHE manifest** is now automatically maintained by the project management system:

- **Purpose**: Comprehensive documentation of all datasets created by the data processing pipeline
- **Automatic Updates**: The system detects when datasets change and updates documentation accordingly  
- **Smart Integration**: Manifest updates are automatically logged in `logbook.md`
- **AI Context**: Updated manifests immediately improve AI assistance quality

### Managing the CACHE Manifest:
```r
# Check manifest status and update if needed
check_cache_manifest()

# Force update manifest documentation  
update_cache_manifest()
```

## 🔗 Project Pipeline

`./pipeline.md` outlines the flow of analytic work specific to this project.

## 🔁 Use Case


Use this framework to launch any project that aims to:
- Maintain high interpretability in AI-assisted analytics
- Avoid black-box decisions and silent assumptions
- Structure team handoffs or long-running analytic workflows
- Build cumulative knowledge over iterative modeling cycles

## 🧭 Getting Started

1. Fork or clone this repository.
2. Initiate `./data-private/raw/research_request.md` to document your research request and its evolution. You will add communication feedback from the client here to trace the evolution of the research request.
3. Customize `./ai/mission.md` to define your project's purpose, axioms, and logic.
4. Tailor `./ai/glossary.md` to your domain.
5. Begin logging analytic moves in `./ai/logbook.md`.
6. Ensure AI agents are prompted using the `./ai/onboarding_ai.md` structure.

## 📜 Attribution

Developed collaboratively by [Andriy Koval](https://github.com/andkov) and ChatGPT-4o, building on a dialectical epistemology of human–AI symbiosis.

> AI contributions provided by OpenAI's ChatGPT, operating under the guidance of the human author. Attribution preferred as:
>
> **"Human–AI co-developed framework using ChatGPT-4o under the authorship and epistemic direction of Andriy Koval."**

## 📘 License

MIT License — open for modification, redistribution, and adaptation with attribution.
