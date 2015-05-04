-- initialize an wikipedia_corpus object, giving it a folder of folders containing output files from Wikipedia-Extractor.py
-- -- the folder should only contain files with wikipedia text or folders with files of wikipedia text
-- the class searches through the folder finding the folder/file/character where each article starts, and stores the name of the article with that location information. All of these are stored in a list-style table.
--  -- while going through the list, it should store all of the unique words
-- the class can then generate a subclass object that is an iterator over a random order on that list. the subclass object has a method that gives the next article, which is also an iterator over words in the article.
-- the article iterator object keeps track of how many articles it has dispatched and how many are left

require 'lfs'
random_article_iterator = require 'random_article_iterator' 

local wikipedia_corpus = {}
wikipedia_corpus.__index = wikipedia_corpus

function wikipedia_corpus.new(corpus_path)
    if corpus_path == nil then error('need corpus path') end
    local self = setmetatable({}, wikipedia_corpus)
    self.corpus_path = corpus_path
    print('Scanning corpus directory tree...')
    self:add_text_file_paths()
    print('Adding articles...')
    self:add_articles()
    print('Building vocabulary...')
    self:build_vocabulary()
    return self
end

function wikipedia_corpus.get_article(self, number)
    local text_file = io.open(self.article_paths[number])
    text_file:seek('set', self.article_starts[number])
    local content = text_file:read(self.article_stops[number] - 
        self.article_starts[number])
    return content 
end

function wikipedia_corpus.add_text_file_paths(self)
    self.text_file_paths = {}
    local path = self.corpus_path
    self:add_text_files_recursively(path)
end

function wikipedia_corpus.add_text_files_recursively(self, path)
    for file_name in lfs.dir(path) do
        if lfs.attributes(path..'/'..file_name,"mode") == "file" then 
            table.insert(self.text_file_paths, path..'/'..file_name)
        elseif lfs.attributes(path..'/'..file_name,"mode") == "directory" and 
            file_name ~= '.' and file_name ~= '..' then 
            self:add_text_files_recursively(path..'/'..file_name)
        end
    end
end

function wikipedia_corpus.add_articles(self)
    self.article_titles = {}
    self.article_starts = {}
    self.article_stops = {}
    self.article_paths = {}
    for ind, file_path in pairs(self.text_file_paths) do
        self:add_file_articles(file_path)
    end 
end

function wikipedia_corpus.add_file_articles(self, file_path)
    local file = io.open(file_path, "r")
    local not_done = true  
    while not_done do
        line = file:read()
        if line == nil then
            not_done = false
        elseif line:sub(1,4) == '<doc' then
            local start,stop = line:find('title')
            local title_start = stop+3
            local title_stop = title_start+line:sub(title_start,-1):find('\"')
            local title = line:sub(title_start,title_stop-2)
            table.insert(self.article_titles, title)
            file:read() -- skips the second title line so the next file:seek() 
                        --is at the content
            table.insert(self.article_starts, file:seek())
        elseif line:sub(1,6) == '</doc>' then
            table.insert(self.article_stops, file:seek()-line:len()-1)
            table.insert(self.article_paths, file_path)
        end 
    end
end 

function wikipedia_corpus.build_vocabulary(self)
    -- vocabulary will be a word->num_occurrences dictionary
    local vocabulary = {}

    function scan_file(text_file)
        local not_done = false
        local line = text_file:read()           
        if line ~= nil then not_done = true end
        while not_done do
            for word in line:gmatch("%S+") do 
                if vocabulary[word] == nil then
                    vocabulary[word] = 1
                else
                    vocabulary[word] = vocabulary[word]+1
                end
            end
            line = text_file:read()           
            if line == nil then not_done = false end
        end
    end

    for ind, file_name in pairs(self.text_file_paths) do
        local text_file = io.open(file_name, 'r')
        scan_file(text_file)
    end
    self.vocabulary = vocabulary
end

function wikipedia_corpus.make_random_iterator(self)
    return random_article_iterator.new(self) 
end

return wikipedia_corpus
