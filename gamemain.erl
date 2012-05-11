-module(gamemain).
-export([main/0]).

main() ->
    gameserver:start().
