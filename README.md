# Books of Ukraine 

This project explores Ukrainian book publication data from the [Ukrainian Book Chamber](http://www.ukrbook.net/), providing insights into publishing trends, language use, genre prevalence, and regional distributions since 2005.

## 🚀 **Ellis Pipeline**: 4-Stage Data Processing System

Our **modular Ellis Pipeline** transforms raw data into analysis-ready formats:

- **Stage 0**: Core book publication data (5 main categories)
- **Stage 1**: Ukrainian administrative data integration (hromadas, oblasts)  
- **Stage 2**: Modular custom data with **bilingual Ukrainian/English support**
- **Main**: Analysis-ready tables + CSV exports, aka default database

Note: We preserve Stages 0 and 1 for the guide the understanding of the respective ETL scripts (e.g. `0-ellis.R`, `1-ellis-ua-admin.R`) and their outputs. Only Stage 2 and Main should be used during active analytic phase. 

See `./pipeline.md` for full architecture details.


## 📚 **Getting Started**

1. **Setup**: Follow `guides/setup-google-access.md` for authentication
2. **Quick Start**: See `guides/getting-started.md` 
3. **Add Custom Data**: Use `guides/custom-data-guide.md` (supports Ukrainian/English inputs)
4. **Full Documentation**: Browse `guides/` directory

## 🎯 **For Analysts**

**Ready-to-use Analytical Database**: `data-private/derived/manipulation/SQLite/books-of-ukraine.sqlite`

**CSV Exports**: Available in `data-private/derived/manipulation/CSV/` for external tools

**Analysis Templates**: Explore `analysis/` directory for example workflows

---

## ⚠️ PowerShell tasks and Execution Policy

Some development tasks in `.vscode/tasks.json` invoke PowerShell scripts. To allow these to run on machines with restricted PowerShell execution policy, the tasks include the flags `-ExecutionPolicy Bypass -NoProfile` when invoking PowerShell. This does not change the system's execution policy; it only instructs the PowerShell process started by VS Code to bypass the policy for that run.

If you prefer to change your user execution policy permanently instead, run PowerShell as Administrator and set:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Only do that if you understand the security implications. The current task approach is minimally invasive and safe for development workflows.
