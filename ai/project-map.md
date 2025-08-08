# Project Map

**Generated**:  2025-08-08 11:02:35

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
├── docs/
├── guides/
├── libs/
├── manipulation/
├── philosophy/
├── scripts/
├── utility/
├── books-of-ukraine.Rproj  🔧 RStudio project
├── COMMAND-GUIDE.md  📖 Command guide
├── COMMAND-REFERENCE.md  📚 Reference manual
├── config.yml  ⚙️ Configuration
├── context7.json  🗂️ Context data
├── FLOW-USAGE.md  🔄 Flow usage guide
├── flow.R  ⚡ Main workflow
├── pipeline.md  📋 Data pipeline docs
└── README.md  📄 Project overview
├── ai/  🧠 Context mgmt & AI memory
│   ├── CACHE-manifest-example.md  📋 Template
│   ├── CACHE-manifest.md  📊 Dataset docs
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
│   ├── semiology.md  🔤 Symbols guide
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
├── docs/  📚 Setup guides
│   ├── google-auth-setup.md  🔐 Google auth setup
│   └── service-account-setup.md  🔑 Service account setup
├── guides/  📖 User workflows
│   └── setup-google-access.md  🌐 Google access guide
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
│   ├── clean-and-load-core-context.R  � Context clean
│   ├── common-chunks.R  📄 Common chunks
│   ├── common-functions.R  🛠️ Shared utils
│   ├── context-refresh.R  � Context refresh
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
