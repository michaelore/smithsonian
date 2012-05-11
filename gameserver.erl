-module(gameserver).
-behaviour(gen_server).
-export([start/0, introduce/0, send_update/1, stop/0, request_matrix/0, store/2, lookup/1]).
-export([init/1, handle_call/3, handle_cast/2, terminate/2]).

initMat() ->
    initMat({0, 0}, dict:new()).
initMat({9, 9}, Acc) ->
    dict:store("X9Y9", "/images/x.png", Acc);
initMat({9, Y}, Acc) ->
    initMat({0, Y+1}, dict:store([88, 57, 89, Y+48], "/images/x.png", Acc));
initMat({X, Y}, Acc) ->
    initMat({X+1, Y}, dict:store([88, X+48, 89, Y+48], "/images/x.png", Acc)).

start() ->
    gen_server:start_link({global, gameserver}, gameserver, {initMat(), dict:new()}, []).

introduce() ->
    gen_server:call({global, gameserver}, hello).

request_matrix() ->
    gen_server:call({global, gameserver}, matrix_please).

send_update(Update) ->
    gen_server:cast({global, gameserver}, {update, Update}).

stop() ->
    gen_server:cast({global, gameserver}, stop).

store(Key, Value) ->
    gen_server:cast({global, gameserver}, {store, Key, Value}).

lookup(Key) ->
    gen_server:call({global, gameserver}, {lookup, Key}).

init(Mat) ->
    {ok, WD} = file:get_cwd(),
    yaws:start_embedded(
        WD ++ "/www/",
        [{servername, "louhikko"}, {listen, {0,0,0,0}}]),
    sender:start(sender),
    {ok, Mat}.

handle_call(matrix_please, _, {Mat, Dict}) ->
    {reply, dict:to_list(Mat), {Mat, Dict}};
handle_call({lookup, Key}, _, {Mat, Dict}) ->
    {reply, dict:fetch(Key, Dict), {Mat, Dict}};
handle_call(hello, {From, _}, {Mat, Dict}) ->
    sender:add(sender, From),
    {reply, ok, {Mat, Dict}}.

handle_cast({update, Update}, {Mat, Dict}) ->
    sender:send(sender, Update),
    NewMat = update(Update, Mat),
    {noreply, {NewMat, Dict}};
handle_cast({store, Key, Value}, {Mat, Dict}) ->
    NewDict = dict:store(Key, Value, Dict),
    {noreply, {Mat, NewDict}};
handle_cast(stop, {Mat, Dict}) ->
    {stop, "'stop' was cast", {Mat, Dict}}.

update({Id, Image}, Mat) ->
    dict:store(Id, Image, Mat).

terminate(R, _) ->
    sender:send(sender, {terminated, R}),
    sender:stop(sender).
