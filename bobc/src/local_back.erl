%%%-------------------------------------------------------------------
%%% @author User
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Дек. 2019 21:15
%%%-------------------------------------------------------------------
-module(local_back).
-author("User").

-behaviour(gen_server).
-include_lib("stdlib/include/qlc.hrl").


%% API
-export([
  start_link/3,
  send/1
  ]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(message, {msg_id, msg, from, time}).

-record(state, {websocket, external, remote, chat_id}).

%%%===================================================================
%%% API
%%%===================================================================

send(Msg)->
  io:format("~p~n",[Msg]),
  gen_server:cast(?SERVER, {send, Msg}).

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------

start_link(External, Remote, ChatId) ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [External, Remote, ChatId], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([External, Remote, ChatId]) ->
  listen_new_msg(External),
  forward({enter,External}, Remote),
  {ok, #state{external = External, remote = Remote, chat_id = ChatId}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------


handle_call({websocket_init,  WebSocket}, _From, #state{external = External, remote = Remote, chat_id =ChatId}) ->
  NewState =  #state{websocket = WebSocket, external = External, remote = Remote, chat_id = ChatId},
  Msgs = print_history(ChatId),
  {reply,{ok, Msgs}, NewState};

handle_call(_Request, _From, State) ->
  {reply, ok, State}.





handle_cast({send, #message{ msg = Message, from = From} = Msg}, #state{websocket = WebSocket, chat_id = Chat_id} = State)->
  save_message(Chat_id,{From,Message}),
  WebSocket ! {send,#{msg_id => Msg#message.msg_id, msg => Msg#message.msg, from => Msg#message.from, time => Msg#message.time }},
  {noreply, State};


%%That function take the msg from front and save it in DB. After that it should to send msg to all users
handle_cast({forward, Msg},#state{chat_id = Chat_id, remote = Remote} = State) ->
  {ok, [[From]] } = init:get_argument(sname),
  Message = save_message(Chat_id,{list_to_atom(From), Msg}),
  forward(Message, Remote),
  {noreply, State};

handle_cast({enter, Client_port}, State)->
  State#state.websocket !{ send, #{msg_id => -1, msg =>list_to_binary("User  connected with port " ++ integer_to_list(Client_port)), from => system, time => calendar:local_time()}},
  NewState = #state{websocket =State#state.websocket, external = State#state.external, remote =[Client_port| State#state.remote], chat_id = State#state.chat_id},
  {noreply, NewState};

handle_cast({leave, Client_port}, State)->
  State#state.websocket !{ send, #{msg_id => -1, msg =>list_to_binary("Leave user with port " ++ integer_to_list(Client_port)), from => system, time => calendar:local_time()}},
  Remote = lists:delete(Client_port, State#state.remote),
  NewState = #state{websocket =State#state.websocket, external = State#state.external, remote =Remote, chat_id = State#state.chat_id},
  {noreply, NewState}.







handle_info(_Info, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, State) ->
  forward({leave, State#state.external}, State#state.remote),
  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================



%%%===================================================================
%%% tcp block
%%%===================================================================

forward(_Msg,[])->
    ok;
forward(Msg, [Remote|Ports])->  
   Socket = gen_tcp:connect({127,0,0,1}, Remote, [binary, {active, false}]),
  case Socket of
    {ok, RSocket} ->
      gen_tcp:send(RSocket, term_to_binary(Msg)),
      forward(Msg, Ports);
    {error, Reson} ->
      gen_server:cast(?SERVER, {leave, Remote}),
      io:format("~p~n",[Reson]),
      forward(Msg, Ports);

    Else ->
      io:format("~p~n",[Else])

  end.




listen_new_msg(Remote)->
  Pid = spawn_link(
    fun() ->
      {ok, LSocket} = gen_tcp:listen(Remote, [binary, {active, false}]),
      spawn(fun() -> acceptor(LSocket, Remote) end),
      timer:sleep(infinity)
    end),
  {ok, Pid}.

acceptor(LSocket, Remote)->
  Socket = gen_tcp:accept(LSocket),
  case Socket of
    {ok, RSocket} ->
      spawn(fun() -> acceptor(LSocket, Remote) end),
      handle(RSocket, Remote);
%%    {error, closed} ->
%%      gen_server:cast(?SERVER, {leave, Remote});
    Else ->
      io:format("~p~n",[Else])

  end.

handle(Socket, Remote)->
  case gen_tcp:recv(Socket, 0) of
    {ok, Msg} ->
      Input = binary_to_term(Msg),
      case Input of

        {enter, Client_port} ->
          gen_server:cast(?SERVER, {enter, Client_port});
        {leave, Client_port} ->
          gen_server:cast(?SERVER, {leave,Client_port});
        Message ->
          send(Message)
      end,
      handle(Socket, Remote);
    {error, closed} ->
      io:format("Connection closed~n"),
      gen_tcp:close(Socket),
      acceptor(Socket, Remote)

  end.



%%%===================================================================
%%%Database block
%%%===================================================================
print_history(ChatId)->
  mnesia:start(),
  mnesia:wait_for_tables([list_to_atom(ChatId)], 20000),
  do(qlc:q([#{ msg_id =>X#message.msg_id,msg =>X#message.msg, from =>X#message.from, time =>X#message.time } || X <- mnesia:table(list_to_atom(ChatId))])).

do(Q) ->
  F = fun() -> qlc:e(Q) end,
  {atomic, Val} = mnesia:transaction(F),
  Val.

  save_message(ChatId, {From, Message}) ->
    Row = #message{from = From, msg = Message,
      msg_id = mnesia:dirty_last(list_to_atom(ChatId)) + 1,
      time= calendar:local_time()},
    F = fun() -> mnesia:write(list_to_atom(ChatId),Row, write) end,
    mnesia:transaction(F),
    Row.