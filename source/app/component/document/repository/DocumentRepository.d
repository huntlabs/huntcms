module app.component.document.repository.DocumentRepository;

import hunt.entity;
import hunt.entity.repository;
import app.component.document.model.Document;
import hunt.util.Serialize;
import hunt.logging;

class DocumentRepository : EntityRepository!(Document, int){
    
    // private EntityManager _entityManager;

    // this(EntityManager manager = null){
    //     super(manager);
    //     _entityManager = manager is null ? createEntityManager() : manager;
    // }

    Page!(Document) findPageAll(string[string] conditions, int page, int limit) {
        string strConditions = " 1 ";
        foreach(key, condition; conditions){
            if(condition != ""){
                if(key == "title")
                    strConditions ~= " AND `" ~ key ~ "` LIKE '%" ~ condition ~ "%' ";
                else
                    strConditions ~= " AND `" ~ key ~ "` = '" ~ condition ~ "' ";
            }
        }
        auto condition = new Condition(strConditions);
        auto sortCondition = new Sort();
        // sortCondition.add(new Order(Field.status, OrderBy.DESC));
        // sortCondition.add(new Order(Field.sort, OrderBy.DESC));
        page = page - 1;
        auto pageable = new Pageable((page < 0 ? 0 : page), limit, sortCondition);
        return findAll(condition, pageable);
    }

    int countAllByProjectId(int projectId){
        return cast(int) count(new Condition(" %s = %s ", Field.project_id, projectId));
    }

    int makeCurrect(int projectId){
        EntityManager _entityManager = createEntityManager();
        auto currect = _entityManager.createQuery!(Document)("SELECT d FROM Document d WHERE d.project_id = :projectId ORDER BY d.status DESC, d.sort DESC ")
            .setParameter("projectId", projectId)
            .getSingleResult();

        int curId = currect.id;

        _entityManager.createQuery!(Document)(" update Document d set d.currect = 0 where d.project_id = :projectId ")
            .setParameter("projectId", projectId)
            .exec();
        _entityManager.createQuery!(Document)(" update Document d set d.currect = 0 where d.id = :id ")
            .setParameter("id", curId)
            .exec();
        _entityManager.close();  
         
        return curId;

    }

    int findCurrectNow(int projectId){
        EntityManager _entityManager = createEntityManager();
        auto currect = _entityManager.createQuery!(Document)("SELECT d FROM Document d WHERE d.project_id = :projectId AND d.currect = 1 ")
            .setParameter("projectId", projectId)
            .getSingleResult();
            
        _entityManager.close();    
        if(currect)
            return currect.id;
        return 0;
    }

    Document[] currectList(){
        EntityManager _entityManager = createEntityManager();
        auto res = _entityManager.createQuery!(Document)("SELECT im,b FROM Document im LEFT JOIN im.project b WHERE b.status= 1 and im.status= 1 and im.currect = 1 ORDER BY b.sort=0 ASC, b.sort ")
            .getResultList();
        _entityManager.close();    
        return res;
    }
}