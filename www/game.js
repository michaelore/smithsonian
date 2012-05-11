var server = "/controller.yaws"
var client_id
function click(id) {
    try {
        var op;
        if ($("#" + id).attr("src")=="/images/x.png") {
            op = "clickx";
        } else {
            op = "clicko";
        }
        $.getJSON(server,
                {'op': op, 'id': id},
                update);
    } catch(e) {
        alert(e);
    }
}

function update(data) {
    $("#" + data.id).attr({'src': data.src});
}

function request_update() {
    $.getJSON(server,
            {'op': "update", 'id': client_id},
            function(mat) {
            $.each(mat, function(id, image) {update({'id': id, 'src': image});});
            });
}

$(document).ready(function() {
    $.getJSON(server,
            {'op': "hello"},
            function(obj) {
            $.each(obj.mat, function(id, image) {update({'id': id, 'src': image});});
            client_id = obj.id;
            setInterval("request_update()", 100);
            });
});
