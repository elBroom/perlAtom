$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();
    $('a.delete').click(function(e){
        $.ajax({
            type: "POST",
            url: this.attributes.href.value,
            dataType: "json",
            success: function( response ) {
                debugger;
                if(response.id) $( ".row-id-"+response.id ).remove();
            },
        });
        return false;
    });
});