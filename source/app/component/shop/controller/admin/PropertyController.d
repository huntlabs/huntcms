module app.component.shop.controller.admin.PropertyController;

import hunt.framework;
import hunt.entity;
import app.component.shop.model.ShopProperty;
import app.component.shop.repository.ShopPropertyRepository;
import app.lib.controller.AdminBaseController;
import app.component.system.helper.Paginate;
import app.component.system.helper.Utils;
import hunt.http.codec.http.model.HttpMethod;

class PropertyController : AdminBaseController
{
    mixin MakeController;

 
    @Action string list()
    {    
        uint page = request.get!uint("page" , 1);
        if(page < 1)
            page = 1;

        auto repository = new ShopPropertyRepository();
        int limit = 20 ;  // 每页显示多少条
        auto pageData = repository.findAll(new Pageable(page - 1 , limit));
        JSONValue alldata = pageToJson!ShopProperty(pageData);
        view.assign("types", alldata);
        Paginate temPage = new Paginate("/admincp/shop/propertyies?page={page}" ,
         page , pageData.getTotalPages());
        view.assign("pageView", temPage.showPages());

        return view.render("shop/property/list");
    }

    @Action Response add()
    {
        if (request.methodAsString() == HttpMethod.POST.asString())
        {
            int now = cast(int) time();
            auto repo = new ShopPropertyRepository();
            int id = request.post("id").to!int;
            auto property = repo.findById(id);
            bool isNew = property is null;
            if( isNew )
            {
                property = new ShopProperty();
                property.created = now;
            }
            property.title = request.post("title");
            property.introduce = request.post("introduce");
            property.status = request.post("status").to!int;
            property.option_type = request.post("option_type").to!int;
            property.is_require = request.post("is_require").to!int;
            property.updated = now;
            if(isNew)
                repo.insert(property);
            else
                repo.update(property);

            return new RedirectResponse(request, "/admincp/shop/properties");
        }

        Response response = new Response(request);
		response.setHeader(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_UTF_8.asString());
		response.setContent(view.render("shop/property/add"));
		return response;
    }


    @Action string edit(int id)
    {
        auto repository = new ShopPropertyRepository();
        view.assign("type", repository.findById(id));

        return view.render("shop/property/edit");
    }

    @Action Response del(int id)
    {
        (new ShopPropertyRepository()).removeById(id);
        return new RedirectResponse(request, "/admincp/shop/properties");
    } 
}