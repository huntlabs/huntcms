module app.component.portal.repository.BannerRepository;

import hunt.entity.repository;
import app.component.portal.model.Banner;
import hunt.framework;
import std.json;

class BannerRepository : EntityRepository!(Banner, int)
{
    private EntityManager _entityMnagaer;
    struct Objects
    {
        CriteriaBuilder builder;
        CriteriaQuery!Banner criteriaQuery;
        Root!Banner root;
    }

    this(EntityManager manager = null)
    {
         _entityMnagaer = manager is null ? createEntityManager() : manager;
        super(_entityMnagaer);
    }

    Objects newObjects()
    {
        Objects objects;

        objects.builder = _entityMnagaer.getCriteriaBuilder();
        objects.criteriaQuery = objects.builder.createQuery!Banner;
        objects.root = objects.criteriaQuery.from();
        objects.criteriaQuery.orderBy(objects.builder.asc(objects.root.Banner.sort));

        return objects;
    }

    Banner[] getBannersByPid(int parentId)
    {
        auto objects = this.newObjects();

        auto p1 = objects.builder.equal(objects.root.Banner.pid, parentId);        
        auto typedQuery = _entityMnagaer.createQuery(objects.criteriaQuery.select(objects.root).where( p1 ));
        Banner[] banners = typedQuery.getResultList();
        if(banners.length > 0)
            return banners;
        return null;
    }
}