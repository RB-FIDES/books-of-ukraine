# Folder Architecture Clarification - FIDES Framework vs Project Implementation

**Date**: 2025-08-19  
**Context**: Human-initiated clarification of folder purposes following ontology.md → glossary.md content migration  
**Impact**: Establishes clear conceptual hierarchy for all future file organization decisions

---

## 🏗️ **Architectural Intent Definition**

### **`./philosophy/` - Universal FIDES Framework** 🔬
- **Scope**: Cross-project foundational principles  
- **Stability**: Framework-level concepts that remain consistent across implementations
- **Purpose**: Define the universe of AI-human symbiosis for research analytics
- **Audience**: Anyone implementing FIDES methodology on any research domain
- **Longevity**: Stable, foundational content that evolves slowly
- **Examples**: Causal inference principles, general ontological frameworks, epistemological foundations, research methodology principles

### **`./ai/` - Project-Specific Symbiotic Collaboration** 📊
- **Scope**: Books-of-Ukraine project implementation  
- **Adaptability**: Context-specific applications of FIDES principles
- **Purpose**: Operational AI-human collaboration for this specific analytical project
- **Audience**: This project's analysts and AI agents
- **Longevity**: Dynamic, project-specific content that evolves with research progress
- **Examples**: Ukrainian publishing glossary, project memory system, CACHE manifests, domain-specific operational guidance

---

## 🎯 **Triggering Event: Content Migration Analysis**

### **ontology.md → glossary.md Move Rationale**
- **FROM**: `./philosophy/ontology.md` (universal concepts)
- **TO**: `./ai/glossary.md` (project-specific terminology)  

**Why This Move Makes Sense**:
The content evolved from general ontological concepts to **Ukrainian publishing domain-specific terms** that are essential for this project's AI-human collaboration but wouldn't apply universally across all FIDES implementations.

### **Content Evolution Pattern**
```
Universal Ontology → Domain-Specific Glossary
Framework Principles → Implementation Terminology  
Cross-Project Concepts → Project-Specific Definitions
```

---

## 🔄 **Implementation Implications**

### **File Placement Decision Framework**
**Before placing any new file, ask:**
1. **"Does this apply to ALL research projects using FIDES?"** → `./philosophy/`
2. **"Is this specific to Ukrainian publishing research?"** → `./ai/`
3. **"Could other researchers use this for different domains?"** → `./philosophy/`
4. **"Does this require Books-of-Ukraine context to understand?"** → `./ai/`

### **Content Migration Guidelines**
**When content evolves from universal to project-specific:**
- Document the migration reason (as done with ontology → glossary)
- Preserve the conceptual value in both contexts
- Consider whether universal principles should remain in `./philosophy/` while project implementation goes to `./ai/`

### **Architectural Benefits Achieved**
1. **Clear Separation of Concerns** - Framework vs. Implementation
2. **Reusability** - FIDES principles can be applied to other research domains  
3. **Maintenance** - Universal concepts stable, project-specific content can evolve freely
4. **Onboarding** - New projects can adopt FIDES framework while customizing AI collaboration
5. **Scalable Pedagogy** - Universal teaching principles with project-specific applications

---

## 📋 **Current File Audit Status**

### **Files Properly Categorized** ✅
**`./philosophy/` (Universal FIDES)**:
- `analysis-templatization.md` - General templating methodology
- `causal-inference.md` - Universal research principles  
- `FIDES.md` - Core framework definition
- `semiology.md` - General research semiotics
- `threats-to-validity.md` - Universal validity concerns

**`./ai/` (Project-Specific)**:
- `glossary.md` - Ukrainian publishing terminology ✅ (recently migrated)
- `mission.md` - Books-of-Ukraine specific objectives
- `method.md` - Project implementation approach  
- `CACHE-MANIFEST-*.md` - Project database documentation
- `memory-*.md` - Project memory system

### **Files Requiring Review** ⚠️
*None identified at this time - architecture appears well-aligned*

---

## 🚀 **Strategic Impact**

### **For FIDES Framework Development**
- **Framework Portability**: Clear separation enables FIDES application to other research domains
- **Methodology Stability**: Universal principles can evolve independently from implementation specifics
- **Knowledge Transfer**: Other research teams can adopt FIDES without Ukrainian publishing context

### **For Books-of-Ukraine Project**
- **Implementation Freedom**: Project-specific content can evolve rapidly without affecting framework stability  
- **Context Clarity**: AI agents know when to apply universal principles vs. project-specific knowledge
- **Collaboration Efficiency**: Team members understand the scope and purpose of each documentation area

### **For Future Projects**
- **Template Creation**: This architecture provides a replicable pattern for new FIDES implementations
- **Onboarding Streamlining**: New projects start with universal principles and add project-specific elements
- **Maintenance Reduction**: Clear boundaries prevent conceptual drift and documentation bloat

---

## 🎓 **Educational Value Preserved**

This architectural clarification supports the **scalable pedagogy** approach mentioned in onboarding instructions:
- **Universal teaching principles** (framework methodology) 
- **Project-specific applications** (implementation techniques)

The folder structure now mirrors the **human learning process**:
1. Learn foundational principles (`./philosophy/`)
2. Apply principles to specific context (`./ai/`)  
3. Develop expertise through practice (project execution)

---

## 📊 **Success Metrics**

**Architecture Clarity** ✅: Clear conceptual distinction established  
**Content Alignment** ✅: Existing files properly categorized  
**Migration Logic** ✅: ontology.md → glossary.md move documented and rationalized  
**Future Guidance** ✅: Decision framework created for new files  
**Documentation** ✅: Principles captured in project memory system

**Status**: ✅ **COMPLETE** - Folder architecture clarified and implemented

---

*This clarification establishes the conceptual foundation for all future file organization decisions in Books-of-Ukraine and other FIDES framework implementations.*
