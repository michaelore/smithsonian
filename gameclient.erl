-module(gameclient).
-behaviour(gen_server).
-export([start/0, update/2, updates/1, stop/1]).
-export([init/1, handle_call/3, handle_cast/2, terminate/2]).

start() ->
    gen_server:start(gameclient, [], []).

update(PID, Update) ->
    gen_server:cast(PID, {update, Update}).

updates(PID) ->
    gen_server:call(PID, updates).

stop(PID) ->
    gen_server:cast(PID, stop).

init(_) ->
    gameserver:introduce(),
    {ok, queue:new()}.

handle_call(updates, _, Updates) ->
    {reply, queue:to_list(Updates), queue:new()}.

handle_cast({update, Update}, Updates) ->
    {noreply, queue:in(Update, Updates)};
handle_cast(stop, Updates) ->
    {stop, "'stop' was cast", Updates}.

terminate(R, _) ->
    void.
