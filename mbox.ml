
open Netcamlbox

(* An mbox to read from. This module really creates and destroys the mbox. *)
module Readable = struct

  let create name max_nb_msg max_msg_size =
    create_camlbox name max_nb_msg max_msg_size

  (* process as many as possible and tell if more messages
     will come in the future *)
  let process_many box f =
    let msg_ids = camlbox_wait box in
    if msg_ids = [] then
      let () = unlink_camlbox (camlbox_addr box) in
      false
    else
      let () =
        List.iter (fun msg_id ->
            (* data copy is avoided here *)
            f (camlbox_get box msg_id);
            (* free the spot ASAP *)
            camlbox_delete box msg_id
          ) msg_ids
      in
      true
end

(* An mbox to write to. It is only retrieved, not created by this module. *)
module Writable = struct

  let create name =
    camlbox_sender name

  (* WARNING: may block until enough space in dst box;
     serialization is done here *)
  let write box msg =
    camlbox_send box msg

  (* tell the reader no more messages will come from me *)
  let end_of_input box =
    camlbox_wake box

end