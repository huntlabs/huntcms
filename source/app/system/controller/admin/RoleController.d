module app.system.controller.admin.RoleController;

import hunt;
import app.common.controller.AdminBaseController;

import app.system.model.Role;
import app.system.repository.RoleRepository;

class RoleController : AdminBaseController
{
    mixin MakeController;
 
    this()
    {
        super();      
    }

    @Action string list()
    {
        auto repository = new RoleRepository;

        view.assign("permissions", repository.findAll());

        return view.render("system/role/list");
    }

    @Action string add()
    {
        return view.render("system/role/add");
    }

    @Action string edit()
    {
        auto repository = new RoleRepository;
        
        //view.assign("permissions", repository.findById( request.get!int("id", 0) ));

        return view.render("system/role/add");
    }
}
