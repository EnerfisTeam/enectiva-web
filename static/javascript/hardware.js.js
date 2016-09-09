$(document).ready(function(){
    var first = true    //variable to control if the page has been loaded
    $(".hardware__menu-item").click(function(){         
        var factor=1    //variable that manage the time of the animation.
        var animationTime = 200
        if (first) {      //if is not the first interraction set the factor to 1 to see the right animation time
            factor=0;     
        }
                      
        first = false;
        
        data_group = $(this).attr('data-group');    //string with the data-group of the button clicked
        $("div.hardware__section[data-group!=" + data_group + "]").fadeOut(animationTime * factor);    //find the divs with the not requested data-group and hide them 
        $("div.hardware__section[data-group=" + data_group + "]").fadeIn(animationTime * factor * 4);  //find the divs with the requested data-group and show them
        $("a[data-group=" + data_group + "]").addClass("hardware__menu-item-selected");     //add the class with the shadow to the button that has been clicked
        $("a[data-group!=" + data_group + "]").removeClass("hardware__menu-item-selected");    //remove the class with the shadow to the buttons that has not been clicked
    });
    
    if(window.location.hash) {    //find if there's an hash in the URL
        var hash = window.location.hash.substr(1);      //string with the name of the requested section extrapolated after the hash from the URL 
        if($("a[data-group=" + hash + "]") != null)    //if the string corrisponds to one of the four sections call the click function and simulate the click on the button relative to the requested section
            $("a[data-group=" + hash + "]").click();
    } 
    else {
        if ($(".hardware__menu-item").length) {
            $(".hardware__menu-item").first().click();    //if there's no hash in the URL call the function with the default behaviour(click on first button)
            var url = window.location + "#" + $(".hardware__menu-item").first().attr('data-group');
            window.location.replace(url);
        }            
    }       
});