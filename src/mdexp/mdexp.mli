(*_********************************************************************************)
(*_  mdexp - Literate Programming with Embedded Snapshots                         *)
(*_  SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

module File_processor = File_processor
module Host_language = Host_language
module Located_json = Located_json
module Markdown_lang_id = Markdown_lang_id

module Private : sig
  module Code_config = Code_config
  module Comment_syntax = Comment_syntax
  module Directive = Directive
  module Json5_accumulator = Json5_accumulator
  module Line_processor = Line_processor
  module Located_json = Located_json
  module Snapshot_processor = Snapshot_processor
  module Snapshot_config = Snapshot_config
  module Snapshot_format = Snapshot_format

  module Std : sig
    module Markdown_lang_id = Markdown_lang_id
    module Host_language = Host_language
  end
end
