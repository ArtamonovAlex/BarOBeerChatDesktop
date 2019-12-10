-module(bobc_manager_signin_handler).

-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
  Req = sign_in(Req0),
  {ok, Req, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Returns reply with body = ok if successfully validate user in Mnesia,             %%
%%  Reason if not; Possible reasons: wrong_password, unknown_login, bad_request, ???  %%
%%%%%%%%%%%5%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sign_in(Req0) ->
  HasBody = cowboy_req:has_body(Req0),

  {Login, Password} =
    case cowboy_req:method(Req0) of
      <<"POST">> when HasBody ->
        {ok, PostParams, _Req} = cowboy_req:read_urlencoded_body(Req0),
        Maybe_Login = proplists:get_value(<<"login">>, PostParams),
        Maybe_Password = proplists:get_value(<<"password">>, PostParams),
        {Maybe_Login, Maybe_Password};
      _ ->
        {undefined, undefined}
    end,

  {Code, ResponseBody} =
    case {Login, Password} of
      {_,undefined} ->
        {400, bad_request};
      {undefined,_} ->
        {400, bad_request};
      {Login, Password} ->
        {200, validate_user(Login, Password)}
    end,
  JsonBody = jsone:encode(ResponseBody),
  cowboy_req:reply(Code,#{<<"content-type">> => <<"text/plain; charset=utf-8">>}, JsonBody, Req0).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  TODO: Returns ok if account data equals saved in Mnesia, Reason if not                      %%
%%  Possible reasons: wrong_password, unknown_login, ???                                        %%
%%%%%%%%%%%5%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
validate_user(_Login, _Password) ->
  ok.