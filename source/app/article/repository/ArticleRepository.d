module app.article.repository.ArticleRepository;


import entity.repository;
import app.article.model.Article;
import hunt;

class ArticleRepository : EntityRepository!(Article, int)
{
    this(EntityManager manager = null)
    {
        super(manager);
    }
}
