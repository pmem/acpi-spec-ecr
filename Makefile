PANDOC := pandoc
PANDOC_OPTS += --pdf-engine=xelatex
PANDOC_OPTS += -V geometry:"top=2cm, bottom=2cm, left=2.5cm, right=2.5cm"
PANDOC_OPTS += -V mainfont="DroidSans"
PANDOC_OPTS += -V urlcolor=RoyalBlue
PANDOC_OPTS += --include-in-header=template.tex

SRCS   := $(shell find . -type f \( ! -iname "README*" \) -name '*.md')
OBJS   := $(patsubst %.md,%.pdf,$(SRCS))

all: $(OBJS)

%.pdf: %.md
	$(PANDOC) $(PANDOC_OPTS) -o $@ $<

clean:
	rm -f *.pdf