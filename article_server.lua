-- initialize a article_server object, giving it a folder of folders containing output files from Wikipedia-Extractor.py
-- -- the folder should only contain files with wikipedia text or folders with files of wikipedia text
-- the class searches through the folder finding the folder/file/character where each article starts, and stores the name of the article with that location information. All of these are stored in a list-style table.
--  -- while going through the list, it should store all of the unique words
-- the class can then generate a subclass object that is an iterator over a random order on that list. the subclass object has a method that gives the next article, which is also an iterator over words in the article.
-- the article iterator object keeps track of how many articles it has dispatched and how many are left

require'lfs'
local article_server = {}
article_server.__index = article_server

function article_server.new(corpus_path)
    if corpus_path == nil then error('need corpus path') end
    local self = setmetatable({}, article_server)
    self.corpus_path = corpus_path
    return self
end

function article_server.add_text_file_paths(self)
    self.text_file_paths = {}
    path = self.corpus_path
    self:add_text_files_recursively(path)
end

function article_server.add_text_files_recursively(self, path)
    for file_name in lfs.dir(path) do
        if lfs.attributes(path..'/'..file_name,"mode") == "file" then 
            print("found file, "..path..'/'..file_name)
            table.insert(self.text_file_paths, path..'/'..file_name)
        elseif lfs.attributes(path..'/'..file_name,"mode") == "directory" and 
            file_name ~= '.' and file_name ~= '..' then 
            print("found directory, "..path..'/'..file_name)
            self:add_text_files_recursively(path..'/'..file_name)
        end
    end
end

function article_server.add_articles(self)
    self.article_titles = {}
    self.article_starts = {}
    self.article_stops = {}
    self.article_paths = {}
    for ind, file_path in pairs(self.text_file_paths) do
        self:add_file_articles(file_path)
    end 
end

function article_server.add_file_articles(self, file_path)
    file = io.open(file_path, "r")
    not_done = true  
    while not_done do
        line = file:read()
        if line == nil then
            not_done = false
        elseif line:sub(1,4) == '<doc' then
            start,stop = line:find('title')
            title_start = stop+3
            title_stop = title_start+line:sub(title_start,-1):find('\"')
            title = line:sub(title_start,title_stop-2)
            table.insert(self.article_titles, title)
            table.insert(self.article_starts, file:seek()-line:len()-1)
        elseif line:sub(1,4) == '</do' then
            table.insert(self.article_stops, file:seek()-line:len()-1)
            table.insert(self.article_paths, file_path)
        end 
    end
end


return article_server
