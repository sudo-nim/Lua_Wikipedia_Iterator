require 'torch'

local random_article_iterator = {}
random_article_iterator.__index = random_article_iterator

function random_article_iterator.new(wikipedia_corpus)
    local self = setmetatable({}, random_article_iterator) 
    self.wikipedia_corpus = wikipedia_corpus
    self.order = torch.randperm(table.getn(self.wikipedia_corpus.article_titles))
    self.articles_delivered = 0
    return self
end

function random_article_iterator.next(self)
    self.articles_delivered = self.articles_delivered + 1
    return self.wikipedia_corpus:get_article(self.order[self.articles_delivered])
end

function random_article_iterator.articles_left(self)
    return table.getn(self.wikipedia_corpus.article_titles) - self.articles_delivered 
end

function random_article_iterator.articles_so_far(self)
    return self.articles_delivered
end

return random_article_iterator
