$(document).ready(function(){
    
    $(".hardware__menu").removeClass("item__hidden").addClass("item__visible");
    $(".hardware__filters-menu").removeClass("item__hidden").addClass("item__visible");
    $(".hardware__product-promo-title").removeClass("item__visible").addClass("item__hidden");
    
    var hardwareSection="hardware__section"
    var menuItem="hardware__menu-item"
    var menuItemSelected="hardware__menu-item--selected"
    var productPromo="hardware__product-promo"
    var productPromoLast="hardware__product-promo--last"
    var filters="hardware__filters-categories"
    var filtersSelect="hardware__filter-select"
    
    var first = true        
    
    $("." + menuItem).click(function(){         
        var factor=1   
        var animationTime = 200
        if (first) {      
            factor=0;     
        }
                      
        first = false;  
        
        data_group = $(this).attr('data-group');    
        $("div." + hardwareSection + "[data-group!=" + data_group + "]").fadeOut(animationTime * factor);    
        $("div." + hardwareSection + "[data-group=" + data_group + "]").fadeIn(animationTime * factor * 4);  
        $("div." + filters + "[data-group!=" + data_group + "]").fadeOut(animationTime * factor);
        $("div." + filters + "[data-group=" + data_group + "]").fadeIn(animationTime * factor * 4);
        $("a[data-group=" + data_group + "]").addClass(menuItemSelected);     
        $("a[data-group!=" + data_group + "]").removeClass(menuItemSelected);   
    });
    
    if(window.location.hash) {    
        var hash = window.location.hash.substr(1);       
        if($("a[data-group=" + hash + "]") != null)   
            $("a[data-group=" + hash + "]").click();
    } 
    else {
        if ($("." + menuItem).length) {
            $("." + menuItem).first().click();    
            var url = window.location + "#" + $("." + menuItem).first().attr('data-group');
            window.location.replace(url);
        }            
    }
    
    
    $("." + filtersSelect).change(function() {
        $select = $(this);
        property = $select.attr('data-hardware-filter-property');
        category = $select.parents("." + filters).data("group");
        $products = $("div." + hardwareSection + "[data-group=" + category + "] ." + productPromo);
        if($select.val()=="default")
        {
            $products.show().removeClass(productPromoLast);
        }
        else
        {
            $products.not("[data-hardware-filter-property-" + property + "*=\"" + $select.val() + "\"]").hide();
            $products.filter("[data-hardware-filter-property-" + property + "*=\"" + $select.val() + "\"]").show().removeClass(productPromoLast).last().addClass(productPromoLast);
        }
    });
    
    $("." + filtersSelect).ready(function(){
        var items = [];
        $(".filters__item").each (function(){ items.push (this); });
        var a=items.length;
        for(var i=0; i<a-1; i++){
            for(var j=i+1; j<a; j++){
                if(items[i].value==items[j].value) {
                    $("." + filtersSelect + " option[value=\""+ items[j].value +"\"]").not(":first").remove();
                }
                a=items.length;
            }
        }
        
        $("." + filtersSelect).each(function(i, select) {
            var length = $(select).children('option').length;
            if (length == 1) {
                property = $(select).attr('data-hardware-filter-property');
                $("span[data-hardware-filter-property=" + property + "]").remove();
                $(select).remove();
            }
            
        });
        
     });
    
});