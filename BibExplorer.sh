#!/bin/bash
# BibExplorer - Minimalist literature management functions

# Main BibExplorer function - Focus on data consistency
bib() {
  # Temporary results file
  local results_file=$(mktemp)
  
  # Use grep and sed to reliably parse BibTeX file
  # First extract all entry keys
  grep -o '@[^{]*{[^,]*,' ~/papers/refs.bib | while read -r entry; do
    # Extract key
    key=$(echo "$entry" | sed 's/@[^{]*{\([^,]*\),.*/\1/')
    
    # Extract relevant information for each key
    title=$(grep -A 20 "$entry" ~/papers/refs.bib | grep -m 1 'title' | sed 's/.*title *= *{\([^}]*\)}.*/\1/')
    author=$(grep -A 20 "$entry" ~/papers/refs.bib | grep -m 1 'author' | sed 's/.*author *= *{\([^}]*\)}.*/\1/')
    year=$(grep -A 20 "$entry" ~/papers/refs.bib | grep -m 1 'year' | sed 's/.*year *= *{\([^}]*\)}.*/\1/' | sed 's/.*year *= *\([0-9]*\).*/\1/')
    keywords=$(grep -A 20 "$entry" ~/papers/refs.bib | grep -m 1 'keywords' | sed 's/.*keywords *= *{\([^}]*\)}.*/\1/')
    url=$(grep -A 20 "$entry" ~/papers/refs.bib | grep -m 1 'url' | sed 's/.*url *= *{\([^}]*\)}.*/\1/')
    
    # Output to results file
    echo -e "$key\t$title\t$author\t$year\t$keywords\t$url" >> "$results_file"
  done
  
  # Search results using fzf
  cat "$results_file" | fzf -i \
    --delimiter='\t' \
    --with-nth=1,2,3,4,5 \
    --preview="echo -e 'Citation key: \033[1;32m{1}\033[0m\nTitle: \033[1;36m{2}\033[0m\nAuthor: \033[1;33m{3}\033[0m\nYear: \033[1;35m{4}\033[0m\nKeywords: \033[1;31m{5}\033[0m\nURL: {6}'" \
    --preview-window=right:60% \
    --height=50% \
    --multi \
    --bind 'ctrl-y:execute(echo -n {1} | pbcopy)+abort' \
    --bind 'ctrl-o:execute(echo {6} | xargs open)' \
    --header 'CTRL-Y: Copy citation key | CTRL-O: Open URL | ENTER: Open PDF' |
  while read -r line; do
    key=$(echo "$line" | cut -f1)
    pdf=~/papers/refs/"${key}".pdf
    if [ -f "$pdf" ]; then
      open "$pdf"
    else
      echo "PDF file not found: $key"
    fi
  done
  
  rm -f "$results_file"
}

# Literature database debug function
bibdebug() {
  # Use grep and sed to reliably parse BibTeX file
  grep -o '@[^{]*{[^,]*,' ~/papers/refs.bib | while read -r entry; do
    # Extract key
    key=$(echo "$entry" | sed 's/@[^{]*{\([^,]*\),.*/\1/')
    entry_type=$(echo "$entry" | sed 's/@\([^{]*\){.*/\1/')
    
    # Extract relevant information for each key
    title=$(grep -A 20 "$entry" ~/papers/refs.bib | grep -m 1 'title' | sed 's/.*title *= *{\([^}]*\)}.*/\1/')
    author=$(grep -A 20 "$entry" ~/papers/refs.bib | grep -m 1 'author' | sed 's/.*author *= *{\([^}]*\)}.*/\1/')
    
    echo "===== Entry ====="
    echo "Key: $key"
    echo "Type: $entry_type"
    echo "Title: $title"
    echo "Author: $author"
    echo ""
  done | less
}
