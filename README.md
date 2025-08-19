# Books of Ukraine - Data Pipeline

This project analyzes Ukrainian book publication data from the [Ukrainian Book Chamber](http://www.ukrbook.net/), providing insights into publishing trends, language patterns, and regional distributions since 2005.

## 🚀 **Ellis Pipeline**: 4-Stage Data Processing System

Our **modular Ellis Pipeline** transforms raw data into analysis-ready formats:

- **Stage 0**: Core book publication data (5 main categories)
- **Stage 1**: Ukrainian administrative data integration (hromadas, oblasts)  
- **Stage 2**: **NEW** Modular custom data with **bilingual Ukrainian/English support**
- **Final**: Analysis-ready tables + CSV exports

### 🌟 **Key Features**:
- **Bilingual Support**: Input Ukrainian or English data, get standardized English output
- **Configuration-Driven**: Add custom data without R coding  
- **Reproducible**: Complete pipeline reproduction from scratch
- **Multi-Format Output**: SQLite databases + CSV files for external tools

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

*Це головна сторінка нашого проєкту, який досліджує дані [Книжкової Палати України](http://www.ukrbook.net/)*
