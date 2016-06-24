BUILDFILE := ./buildfile.hs
BUILD     := ./_build/build
BUILDDIR  := $(dir $(BUILD))
SOURCES   := $(shell find .)
SOURCES   := $(filter-out ./Makefile,$(SOURCES))
SOURCES   := $(filter-out $(BUILD),$(SOURCES))
SOURCES   := $(filter-out $(BUILDFILE),$(SOURCES))

# Delegate the default task.
default:
	@$(MAKE) $(BUILD)
	@$(BUILD)

# Delegate all file tasks for existing files.
$(SOURCES):
	@$(MAKE) $(BUILD)
	@$(BUILD) "$@"
.PHONY: $(SOURCES)

# Delegate all other tasks.
.DEFAULT:
	@$(MAKE) $(BUILD)
	@$(BUILD) "$@"

# Compile buildfile.hs.
$(BUILD): $(BUILDFILE)
	cabal install shake
	mkdir -p $(BUILDDIR)
	ghc --make $(BUILDFILE) -rtsopts -with-rtsopts=-I0 -outputdir=$(BUILDDIR) -o $(BUILD)

# Clean up the _build directory.
clean:
	@rm -rf $(BUILDDIR)
