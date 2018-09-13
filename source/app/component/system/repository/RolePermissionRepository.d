module app.component.system.repository.RolePermissionRepository;

import hunt.entity;
import hunt.entity.repository;

import app.component.system.model.RolePermission;
import app.component.system.model.Permission;
import app.component.system.repository.PermissionRepository;

class RolePermissionRepository : EntityRepository!(RolePermission, int)
{
    private EntityManager _entityManager;

    struct Objects
    {
        CriteriaBuilder builder;
        CriteriaQuery!RolePermission criteriaQuery;
        Root!RolePermission root;
    }

    this(EntityManager manager = null) {
        super(manager);
        _entityManager = manager is null ? createEntityManager() : manager;
    }

    Permission[] getRolePermissions(int roleId)
    {
        auto objects = this.newObjects();
        auto p1 = objects.builder.equal(objects.root.RolePermission.role_id, roleId);
        auto typedQuery = _entityManager.createQuery(objects.criteriaQuery.select(objects.root).where( p1 ));
        RolePermission[] rolePermissions = typedQuery.getResultList();

        Permission[] permissions;
        auto permissionRepository = new PermissionRepository();

        foreach (rolePermission; rolePermissions)
        {
            permissions ~= permissionRepository.findById(rolePermission.permission_id);
        }

        return permissions;
    }

    int[] getRolePermissionIds(int roleId)
    {
        auto objects = this.newObjects();

        auto p1 = objects.builder.equal(objects.root.RolePermission.role_id, roleId);
        auto typedQuery = _entityManager.createQuery(objects.criteriaQuery.select(objects.root).where( p1 ));
        RolePermission[] rolePermissions = typedQuery.getResultList();

        int[] ids;
        foreach (rolePermission; rolePermissions)
        {
            ids ~= rolePermission.permission_id;
        }

        return ids;
    }

    bool saves(int roleId, int[] permissionIds)
    {
        RolePermission[] rolePermission;
        foreach(permissionId; permissionIds){
            RolePermission r = new RolePermission();
            r.role_id = roleId;
            r.permission_id = permissionId;
            rolePermission ~= r;
        }
        this.saveAll(rolePermission);
        return true;
    }

    bool removes(int roleId)
    {
        auto objects = this.newObjects();
        auto p1 = objects.builder.equal(objects.root.RolePermission.role_id, roleId);
        auto typedQuery = _entityManager.createQuery(objects.criteriaQuery.select(objects.root).where( p1 ));
        RolePermission[] rolePermissions = typedQuery.getResultList();
        this.removeAll(rolePermissions);
        return true;
    }

    Objects newObjects()
    {
        Objects objects;

        objects.builder = _entityManager.getCriteriaBuilder();
        objects.criteriaQuery = objects.builder.createQuery!RolePermission;
        objects.root = objects.criteriaQuery.from();
        return objects;
    }
}
