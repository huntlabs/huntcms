module app.component.shop.controller.admin.ProductCategoryController;

import hunt.framework;
import hunt.framework.simplify;
import hunt.framework.http.RedirectResponse;
import std.uri;
import kiss.logger;
import kiss.datetime.format;
import app.lib.controller.AdminBaseController;
import app.component.shop.repository.ProductCategoryRepository;
import app.component.shop.model.ProductCategory;
import app.component.shop.repository.ProductTypeRepository;
import app.lib.other.Paginate;

class ProductCategoryController : AdminBaseController
{
    mixin MakeController;

    this()
    {
        super();
    }

    @Action string list()
    {
        auto conditions = request.all();
        int limit = 20 ;  // 每页显示多少条
        foreach (key, condition; conditions)
        {
            conditions[key] = decodeComponent(condition);
        }
        auto productCategoryRepository = new ProductCategoryRepository();
        auto list = productCategoryRepository.adminList(conditions, limit);
        view.assign("data", list["data"]);
        view.assign("get", conditions);

        uint page = request.get!uint("page" , 1);
        string linkUrl = request.fullUrl();
        if (indexOf(linkUrl, "page="~page.to!string) != -1){
            linkUrl = linkUrl.replace("page="~page.to!string, "page={page}");
        }else {
            if (indexOf(request.fullUrl(), "?") != -1){
                linkUrl ~= "&page={page}";
            }else {
                linkUrl ~= "?page={page}";
            }
        }
        Paginate pageView = new Paginate(linkUrl , (cast(int) page <= 0 ? 1 : cast(int) page) , to!int(list["total_page"].integer), limit);
        view.assign("pageView", pageView.showPages());
        view.assign("categorys", productCategoryRepository.all());
        return view.render("shop/productCategory/list");
    }

    @Action Response add()
    {
        auto productCategoryRepository = new ProductCategoryRepository();
        if (request.method == "POST")
        {
            auto productCategoryModel = new ProductCategory();
            int time = time();
            productCategoryModel.title = request.post("title");
            productCategoryModel.sort = request.post("sort").to!int;
            productCategoryModel.pid = request.post("pid").to!int;
            auto parentData = productCategoryRepository.find(productCategoryModel.pid);
            if(parentData){
                productCategoryModel.level = ++parentData.level;
                productCategoryModel.status = request.post("status").to!short;
                productCategoryModel.updated = time;
                productCategoryModel.created  = time;
                auto save = productCategoryRepository.save(productCategoryModel);
                if (save !is null)
                {
                    return new RedirectResponse(createUrl("shop.productcategory.list"));
                }else {
                    view.assign("errorMessages", ["操作失败"]);
                }
            }else{
                view.assign("errorMessages", ["未找到上级分类数据"]);
            }

        }
        view.assign("categorys", productCategoryRepository.all());
        return request.createResponse().setContent(view.render("shop/productCategory/add"));
    }

    @Action Response edit(int id)
    {
        auto productCategoryRepository = new ProductCategoryRepository();
        if (request.method == "POST")
        {
            auto productCategoryModel = productCategoryRepository.find(id);
            int time = time();
            productCategoryModel.id = id;
            productCategoryModel.title = request.post("title");
            productCategoryModel.sort = request.post("sort").to!int;
            productCategoryModel.status = request.post("status").to!short;
            productCategoryModel.updated = time;
            auto save = productCategoryRepository.save(productCategoryModel);
            if (save !is null)
            {
                return new RedirectResponse(createUrl("shop.productcategory.list"));
            }else {
                view.assign("errorMessages", ["操作失败"]);
            }
        }
        view.assign("data",  productCategoryRepository.find(id));
        view.assign("categorys", productCategoryRepository.all());
        return request.createResponse().setContent(view.render("shop/productCategory/edit"));
    }

    @Action Response del(int id)
    {
        auto productCategoryRepository = new ProductCategoryRepository();
        if(productCategoryRepository.childrens(id))
        {
            return new RedirectResponse(createUrl("shop.productcategory.list"));
        }
        auto productCategoryModel = productCategoryRepository.find(id);
        productCategoryRepository.remove(productCategoryModel);
        return new RedirectResponse(createUrl("shop.productcategory.list"));
    }

}