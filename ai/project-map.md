# Project Map

**Generated**:  2├── a│   ├── CACHE-manifest-analytical.md  📊 A├── guides/  📚 Setup & usage guides
│   ├── getting-started.md  🚀 New device setup
│   ├── flow-usage.md  🔄 Flow usage guide
│   ├── command-guide.md  📖 Command guide
│   ├── command-reference.md  📚 Reference manual
│   ├── memory-system-guide.md  🧠 Memory system demo
│   ├── setup-google-access.md  🔑 Google auth setup
│   └── google-service-account-template.json  📋 Template tables
│   ├── CACHE-manifest-0.md  📊 Core star schema (0-ellis.R)
│   ├── FIDES.md  🔬 Research framework
│   ├── glossary.md  📖 Terms
│   ├── INPUT-manifest.md  📥 Input data docs
│   ├── logbook.md  📝 Change log
│   ├── method.md  📐 Methodsontext mgmt & AI memory
│   ├── CACHE-manifest-0.md  📊 Core star schema (0-ellis.R)
│   ├── CACHE-MANIFEST-1.md  📊 Enhanced DB (1-ellis.R)
│   ├── CACHE-manifest-analytical.md  📊 Analysis tables (last-ellis.R)08-08 11:02:35

## 🗂️ Books of Ukraine - Project Structure Tree

**Mission**: Investigate Ukrainian publishing trends (2005+), regional differences, Russian language patterns
**Tech Stack**: R/Quarto + SQLite + Google Sheets | **Team**: Research & Data Science Unit

```
books-of-ukraine/  🏠 Project config & docs
├── _cleanup/
├── ai/
├── analysis/
├── data-private/
├── data-public/
├── guides/
├── libs/
├── manipulation/
├── philosophy/
├── scripts/
├── utility/
├── books-of-ukraine.Rproj  🔧 RStudio project
├── config.yml  ⚙️ Configuration
├── context7.json  🗂️ Context data
├── flow.R  ⚡ Main workflow
├── pipeline.md  📋 Data pipeline docs
└── README.md  📄 Project overview
├── guides/  📚 Setup & usage guides
│   ├── getting-started.md  🚀 New device setup
│   ├── flow-usage.md  🔄 Flow usage guide
│   ├── command-guide.md  📖 Command guide
│   ├── command-reference.md  📚 Reference manual
│   └── setup-google-access.md  🔑 Google auth setup
├── ai/  🧠 Context mgmt & AI memory
│   ├── CACHE-MANIFEST-1.md  📊 Enhanced DB
│   ├── CACHE-manifest-analytical.md  � Analysis tables
│   ├── CACHE-manifest-0.md  📊 Core star schema (0-ellis.R)
│   ├── FIDES.md  🔬 Research framework
│   ├── glossary.md  📖 Terms
│   ├── INPUT-manifest.md  📥 Input data docs
│   ├── logbook.md  📝 Change log
│   ├── memory-system-demo.md  🧠 Memory demo
│   ├── method.md  📐 Methods
│   ├── mission.md  🎯 Project aims
│   ├── onboarding-ai.md  🤖 AI config
│   ├── project-map.md  📄 Docs
│   ├── project-memory.md  🧠 Decisions log
│   ├── README.md  📄 Project overview
│   ├── semiology.md  🔤 Symbols guide  (note: canonical file is `./philosophy/semiology.md`)
│   └── vscode-tasks-reference.md  🔧 VS Code tasks
├── analysis/  📊 Reports & EDA
│   ├── analysis-templatization/
│   ├── Data-visualization/
│   ├── eda-1/
│   ├── eda-2/
│   ├── report-example/
│   ├── report-example-2/
│   ├── report-example-3/
│   ├── IDEAS.md  💡 Analysis ideas
│   ├── looker-studio-assessment.md  📊 Looker assessment
│   └── README.md  📄 Project overview
├── data-private/  🔒 Datasets (private)
│   ├── derived/
│   ├── raw/
│   ├── contents.md  📄 Data contents
│   └── README.md  📄 Project overview
├── data-public/  📂 Datasets (public)
│   ├── derived/
│   ├── metadata/
│   ├── raw/
│   └── README.md  📄 Project overview
├── guides/  📚 Setup & usage guides
│   ├── getting-started.md  � New device setup
│   ├── flow-usage.md  � Flow usage guide
│   ├── command-guide.md  📖 Command guide
│   ├── command-reference.md  📚 Reference manual
│   ├── setup-google-access.md  🔑 Google auth setup
│   └── google-service-account-template.json  📋 Template
├── libs/  📦 Shared libraries
│   ├── docs/
│   └── images/
├── manipulation/  🔧 Data processing
│   ├── archive/
│   ├── data-local/
│   ├── prints/
│   ├── 0-ellis-original-input.R  📥 Original import
│   ├── 0-ellis.R  📥 Data import
│   ├── 1-ellis.R  🔄 Data processing
│   └── README.md  📄 Project overview
├── philosophy/  🤔 Methods & frameworks
│   ├── images/
│   ├── analysis-templatization.md  📝 Analysis templates
│   ├── causal-inference.md  🔬 Causal methods
│   ├── fides-example.md  📖 FIDES example
│   ├── FIDES.md  🔬 Research framework
│   ├── ontology.md  🧬 Data ontology
│   └── threats-to-validity.md  ⚠️ Validity threats
├── scripts/  ⚙️ Automation & utilities
│   ├── graphing/
│   ├── modeling/
│   ├── sql/
│   ├── templates/
│   ├── ai-memory-functions.R  🧠 Memory system
│   ├── check-setup.R  ✅ Setup check
│   ├── common-chunks.R  📄 Common chunks
│   ├── common-functions.R  🛠️ Shared utils
│   ├── google-auth-helper.R  � Google auth
│   ├── load-core-context.R  📚 Context loader
│   ├── operational-functions.R  ⚙️ Operations
│   ├── README.md  📄 Project overview
│   ├── service-account-auth.R  � Service auth
│   ├── setup-google-auth.R  � Auth setup
│   ├── test-service-account.R  🧪 Auth test
│   └── update-copilot-context.R  🤖 Context mgmt
└── utility/  🛠️ Project maintenance
    ├── common-headers.R  � Common headers
    ├── install-packages.R  📦 Package install
    └── README.md  📄 Project overview
```

---

## 🚀 Quick Commands

**Setup & Status**: `context_refresh()` • `analyze_project_status()` • `check_cache_manifest()`
**Data Pipeline**: `manipulation/0-ellis.R` → `check_cache_manifest()` → `analysis/eda-*`
**Help**: `get_command_help('function_name')` • `ai/logbook.md` • `ai/README.md`

*Auto-maintained. Use `update_project_map()` to refresh.*
