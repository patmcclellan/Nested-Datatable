({
    afterRender : function( cmp, helper ) 
    {
        this.superAfterRender();
        var didScrolled;
        var div = cmp.find('scroll_container');
        
        console.log(JSON.stringify(div));
        if(!$A.util.isEmpty(div)){
            div = div.getElement();
            div.onscroll = function(){
                didScrolled = true;
                };
            //Interval function to check if the user scrolled or if there is a scrollbar
            var intervalId = setInterval($A.getCallback(function(){
                if(didScrolled){
                    didScrolled = false;
                    if(div.scrollTop === (div.scrollHeight - div.offsetHeight)){
                        if(! cmp.get("v.searching"))
                        { 
                            helper.getDataMap(cmp);
                        }
                    }
                }
            }), 750);
            cmp.set('v.intervalId', intervalId);
        }
    },
    unrender: function( cmp) {
        this.superUnrender();
        var intervalId = cmp.get( 'v.intervalId' );
        if ( !$A.util.isUndefinedOrNull( intervalId ) ) {
            window.clearInterval( intervalId );
        }
    }
})