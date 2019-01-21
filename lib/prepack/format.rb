# frozen_string_literal: true

module Prepack
  module Format
    def self.to(type, &block)
      define_method(:"to_#{type}", &block)
    end

    to(:alias) { "alias #{source(0)} #{source(1)}" }
    to(:aref) { body[1] ? "#{source(0)}[#{source(1)}]" : "#{source(0)}[]" }
    to(:aref_field) { "#{source(0)}[#{source(1)}]" }
    to(:arg_paren) { body[0].nil? ? '' : "(#{source(0)})" }
    to(:args_add) { starts_with?(:args_new) ? source(1) : join(',') }
    to(:args_add_block) do
      args, block = body

      parts = args.is?(:args_new) ? [] : [args.to_source]
      parts << parts.any? ? ',' : "&#{block.to_source}" if block

      parts.join
    end
    to(:args_add_star) { starts_with?(:args_new) ? "*#{source(1)}" : "#{source(0)},*#{source(1)}" }
    to(:args_new) { '' }
    to(:assign) { "#{source(0)} = #{source(1)}" }
    to(:array) { body[0].nil? ? '[]' : "#{starts_with?(:args_add) ? '[' : ''}#{source(0)}]" }
    to(:assoc_new) { starts_with?(:@label) ? join(' ') : join(' => ') }
    to(:assoclist_from_args) { body[0].map(&:to_source).join(',') }
    to(:begin) { "begin\n#{join("\n")}\nend" }
    to(:BEGIN) { "BEGIN {\n#{source(0)}\n}"}
    to(:binary) { "#{source(0)} #{body[1]} #{source(2)}" }
    to(:block_var) { "|#{source(0)}|" }
    to(:bodystmt) { body.compact.map(&:to_source).join("\n") }
    to(:brace_block) { " { #{body[0] ? source(0) : ''}#{source(1)} }" }
    to(:call) { "#{source(0)}#{source(1)}#{body[2] === 'call' ? '' : source(2)}" }
    to(:class) { "class #{source(0)}#{body[1] ? " < #{source(1)}\n" : ''}#{source(2)}\nend" }
    to(:command) { join(' ') }
    to(:const_path_field) { join('::') }
    to(:const_path_ref) { join('::') }
    to(:const_ref) { source(0) }
    to(:def) { "def #{source(0)}\n#{source(2)}\nend" }
    to(:defined) { "defined?(#{source(0)})" }
    to(:do_block) { " do#{body[0] ? " #{source(0)}" : ''}\n#{source(1)}\nend" }
    to(:END) { "END {\n#{source(0)}\n}"}
    to(:else) { "else\n#{source(0)}" }
    to(:elsif) { "elsif #{source(0)}\n#{source(1)}#{body[2] ? "\n#{source(2)}" : ''}" }
    to(:fcall) { join }
    to(:field) { join }
    to(:hash) { body[0].nil? ? '{}' : "{ #{join} }" }
    to(:if) { "if #{source(0)}\n#{source(1)}\n#{body[2] ? "#{source(2)}\n" : ''}end" }
    to(:if_mod) { "#{source(1)} if #{source(0)}" }
    to(:ifop) { "#{source(0)} ? #{source(1)} : #{source(2)}"}
    to(:massign) { join(' = ') }
    to(:method_add_arg) { body[1].is?(:args_new) ? source(0) : join }
    to(:method_add_block) { join }
    to(:mlhs_add) { starts_with?(:mlhs_new) ? source(1) : join(',') }
    to(:mlhs_add_post) { join(',') }
    to(:mlhs_add_star) { "#{starts_with?(:mlhs_new) ? '' : "#{source(0)},"}#{body[1] ? "*#{source(1)}" : '*'}" }
    to(:mlhs_paren) { "(#{source(0)})" }
    to(:mrhs_add) { join(',') }
    to(:mrhs_add_star) { "*#{join}" }
    to(:mrhs_new) { '' }
    to(:mrhs_new_from_args) { source(0) }
    to(:module) { "module #{source(0)}#{source(1)}\nend" }
    to(:next) { starts_with?(:args_new) ? 'next' : "next #{source(0)}" }
    to(:opassign) { join(' ') }
    to(:paren) { "(#{join})" }
    to(:params) do
      reqs, opts, rest, post, kwargs, kwarg_rest, block = body
      parts = []

      parts << reqs.map(&:to_source).join if reqs
      parts += opts.map { |opt| "#{opt[0]} = #{opt[1]}" } if opts
      parts << rest.to_source if rest
      parts << post.map(&:to_source).join if post
      parts += kwargs.map { |(kwarg, value)| value ? "#{kwarg} #{value}" : kwarg } if kwargs
      parts << kwarg_rest.to_source if kwarg_rest
      parts << block.to_source if block

      parts.join(',')
    end
    to(:program) { "#{join("\n")}\n" }
    to(:qsymbols_add) { join(starts_with?(:qsymbols_new) ? '' : ' ') }
    to(:qsymbols_new) { '%i[' }
    to(:qwords_add) { join(starts_with?(:qwords_new) ? '' : ' ') }
    to(:qwords_new) { '%w[' }
    to(:sclass) { "class << #{source(0)}\n#{source(1)}\nend" }
    to(:stmts_add) { starts_with?(:stmts_new) ? source(1) : join("\n") }
    to(:string_add) { join }
    to(:string_content) { '' }
    to(:string_embexpr) { "\#{#{source(0)}}" }
    to(:string_literal) { "\"#{source(0)}\"" }
    to(:super) { "super#{starts_with?(:arg_paren) ? '' : ' '}#{source(0)}" }
    to(:symbol) { ":#{source(0)}" }
    to(:symbol_literal) { source(0) }
    to(:symbols_add) { join(starts_with?(:symbols_new) ? '' : ' ') }
    to(:symbols_new) { '%I[' }
    to(:top_const_field) { "::#{source(0)}" }
    to(:top_const_ref) { "::#{source(0)}" }
    to(:unary) { "#{body[0][0]}#{source(1)}" }
    to(:undef) { "undef #{body[0][0].to_source}" }
    to(:unless) { "unless #{source(0)}\n#{source(1)}\n#{body[2] ? "#{source(2)}\n" : ''}end" }
    to(:unless_mod) { "#{source(1)} unless #{source(0)}" }
    to(:until) { "until #{source(0)}\n#{source(1)}\nend" }
    to(:until_mod) { "#{source(1)} until #{source(0)}" }
    to(:var_alias) { "alias #{source(0)} #{source(1)}" }
    to(:var_field) { join }
    to(:var_ref) { source(0) }
    to(:vcall) { join }
    to(:void_stmt) { '' }
    to(:while) { "while #{source(0)}\n#{source(1)}\nend" }
    to(:while_mod) { "#{source(1)} while #{source(0)}" }
    to(:word_add) { join }
    to(:word_new) { '' }
    to(:words_add) { join(starts_with?(:words_new) ? '' : ' ') }
    to(:words_new) { '%W[' }
    to(:yield) { "yield#{starts_with?(:paren) ? '' : ' '}#{join}" }
    to(:yield0) { 'yield' }
    to(:zsuper) { 'super' }
  end
end
