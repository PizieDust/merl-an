open! Import

(** The different kinds of data backends that are supported. *)
type kind = Perf | Regr | Error_regr | Bench

module type Data_channels = sig
  type t
  (** The type representing the streaming channels: several out_channels; each
      of them writing a json-line file. *)

  val kind : kind
  (** The backend kind *)

  val init_cache : t -> bool

  val write_analysis_data :
    id:int ->
    responses:Merlin.Response.t list ->
    cmd:Merlin.Cmd.t ->
    file:File.t ->
    loc:Location.t ->
    query_type:Merlin.Query_type.t ->
    t ->
    unit
  (** Write analysis data of one sample to the streaming channels. *)

  val persist_logs : log:Logs.t -> t -> unit
  (** Append logs. *)

  val all_files : unit -> Fpath.t list
  (** Returns the list of all files to which the data is written. *)

  val with_channels :
    data_dir:Fpath.t ->
    merlin:Merlin.t ->
    proj_paths:Fpath.t list ->
    (t -> 'a) ->
    'a
  (** Scopes the entire channel lifecycle: opens streams, runs the callback,
      writes backend-specific summaries/metadata, and guarantees closing all
      open channels even on exception. *)
end

module Performance : Data_channels
(** The backend for analyzing [merlin]'s performance. *)

type behavior_config = { full : bool; distilled_data : bool }

val behavior : behavior_config -> (module Data_channels)
(** The backend for testing possible end-to-end [merlin] regressions. *)

module Benchmark : Data_channels
