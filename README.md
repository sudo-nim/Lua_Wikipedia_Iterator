# Lua_Wikipedia_Iterator
Small library for serving plain text Wikipedia articles from the output directory of WikiExtractor.py into Lua. Useful for training language models in Torch using a potentially massive Wikipedia corpus without the need to load the corpus into memory.

# Example Usage
```
-- assuming you're in the directory above the cloned repository...
package.path = package.path .. ';./Lua_Wikipedia_Iterator/?.lua'
local wikipedia_corpus = require 'wikipedia_corpus'

wc = wikipedia_corpus.new('Wikipedia_Text')
ri = wc:make_random_iterator()
-- iterate through the plaintext articles using ri:next(). Use ri:<tab> in the TREPL to see other useful functions on ri.
```
