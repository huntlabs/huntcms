module app.component.system.controller.admin.MenuController;

import hunt.framework;

import app.component.system.model.Menu;
import app.component.system.repository.MenuRepository;
import app.lib.controller.AdminBaseController;

import hunt.logging;
import hunt.util.Serialize;
import hunt.util.DateTime;
import app.component.system.helper.Utils;
import hunt.http.codec.http.model.HttpMethod;

import hunt.entity.domain;

class MenuController : AdminBaseController
{
    mixin MakeController;
  
    this()
    {
        super();      
    }

    @Action string list()
    {
        uint page = request.get!uint("page" , 0);
        auto repository = new MenuRepository();
        auto alldata = pageToJson!Menu(repository.findAll(new Pageable(page , 20)));
        //logDebug("menus : ", alldata);
        view.assign("menus", alldata);

        return view.render("system/menu/list");
    }

    @Action Response add()
    {
        if (request.methodAsString() == HttpMethod.POST.asString())
        {
            int now = cast(int) time();
            auto mr = new MenuRepository;
            Menu mn = new Menu;
            mn.pid = request.post("pid").to!int;
            mn.name = request.post("name");
            mn.mca = request.post("mca");
            mn.linkUrl = request.post("linkUrl");
            mn.iconClass = request.post("iconClass" , "");
            mn.sort = request.post("sort").to!int;
            mn.isAction = request.post("actionRadio").to!short;
            mn.status = request.post("statusRadio").to!short;
            auto id = request.post("id");
            if(id.length != 0)
            {
                mn.id = id.to!int;
                auto exsit_data = mr.findById(id.to!int);
                if(exsit_data !is null)
                    mn.created = exsit_data.created;
            }
            else
                mn.created = now;
            mn.updated = now;

            auto saveRes = mr.save(mn);
            if (saveRes !is null)
                return new RedirectResponse(request, "/admincp/system/menus");

        }
        auto repository = new MenuRepository;
        view.assign("firstLevelMenus", repository.getMenusByPid(0));

        Response response = new Response(request);
		response.setHeader(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_UTF_8.asString());
		response.setContent(view.render("system/menu/add"));
		return response;
    }

    @Action string edit(int id)
    {
        logDebug(" edit id : ", id, "  get id : ", request.get("id"));
        auto repository = new MenuRepository;
        view.assign("menu", repository.find(id));
        view.assign("firstLevelMenus", repository.getMenusByPid(0));

        return view.render("system/menu/edit");
    }

    @Action Response del(int id)
    {
        (new MenuRepository).removeById(id);
        return new RedirectResponse(request, "/admincp/system/menus");
    }
}
