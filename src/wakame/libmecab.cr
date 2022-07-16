@[Link(ldflags: "`mecab-config --libs`")]
lib LibMeCab
  struct DictionaryInfoT
    # filename of dictionary
    # On Windows, filename is stored in UTF-8 encoding
    filename : LibC::Char*
    # character set of the dictionary. e.g., "SHIFT-JIS", "UTF-8"
    charset : LibC::Char*
    # How many words are registered in this dictionary.
    size : LibC::UInt
    # dictionary type
    # this value should be MECAB_USR_DIC, MECAB_SYS_DIC, or MECAB_UNK_DIC.
    type : LibC::Int
    # left attributes size
    lsize : LibC::UInt
    # right attributes size
    rsize : LibC::UInt
    # version of this dictionary
    version : LibC::UShort
    # pointer to the next dictionary info.
    next : DictionaryInfoT*
  end

  struct PathT
    # pointer to the right node
    rnode : NodeT*
    # pointer to the next right path
    rnext : PathT*
    # pointer to the left node
    lnode : NodeT*
    # pointer to the next left path
    lnext : PathT*
    # local cost
    cost : LibC::Int
    # marginal probability
    prob : LibC::Float
  end

  struct NodeT
    # pointer to the previous node.
    prev : NodeT*
    # pointer to the next node.
    next : NodeT*
    # pointer to the node which ends at the same position.
    enext : NodeT*
    # pointer to the node which starts at the same position.
    bnext : NodeT*
    # pointer to the right path.
    # this value is NULL if MECAB_ONE_BEST mode.
    rpath : PathT*
    # pointer to the right path.
    # this value is NULL if MECAB_ONE_BEST mode.
    lpath : PathT*
    # surface string.
    # this value is not 0 terminated.
    # You can get the length with length/rlength members.
    surface : LibC::Char*
    # feature string
    feature : LibC::Char*
    # unique node id
    id : LibC::UInt
    # length of the surface form.
    length : LibC::UShort
    # length of the surface form including white space before the morph.
    rlength : LibC::UShort
    # right attribute id
    rc_attr : LibC::UShort
    # left attribute id
    lc_attr : LibC::UShort
    # unique part of speech id. This value is defined in "pos.def" file.
    posid : LibC::UShort
    # character type
    char_type : UInt8
    # status of this model.
    # This value is MECAB_NOR_NODE, MECAB_UNK_NODE, MECAB_BOS_NODE, MECAB_EOS_NODE, or MECAB_EON_NODE.
    stat : UInt8
    # set 1 if this node is best node.
    isbest : UInt8
    # forward accumulative log summation.
    # This value is only available when MECAB_MARGINAL_PROB is passed.
    alpha : LibC::Float
    # backward accumulative log summation.
    # This value is only available when MECAB_MARGINAL_PROB is passed.
    beta : LibC::Float
    # marginal probability.
    # This value is only available when MECAB_MARGINAL_PROB is passed.
    prob : LibC::Float
    # word cost.
    wcost : LibC::Short
    # best accumulative cost from bos node to this node.
    cost : LibC::Long
  end

  # Normal node defined in the dictionary.
  NorNode = 0_i64
  # Unknown node not defined in the dictionary.
  UnkNode = 1_i64
  # Virtual node representing a beginning of the sentence.
  BosNode = 2_i64
  # Virtual node representing a end of the sentence.
  EosNode = 3_i64
  # Virtual node representing a end of the N-best enumeration.
  EonNode = 4_i64

  # This is a system dictionary.
  SysDic = 0_i64
  # This is a user dictionary.
  UsrDic = 1_i64
  # This is a unknown word dictionary.
  UnkDic = 2_i64

  # One best result is obtained (default mode)
  OneBest = 1_i64
  # Set this flag if you want to obtain N best results.
  Nbest = 2_i64
  # Set this flag if you want to enable a partial parsing mode.
  # When this flag is set, the input |sentence| needs to be written
  # in partial parsing format.
  Partial = 4_i64
  # Set this flag if you want to obtain marginal probabilities.
  # Marginal probability is set in MeCab::Node::prob.
  # The parsing speed will get 3-5 times slower than the default mode.
  MarginalProb = 8_i64
  # Set this flag if you want to obtain alternative results.
  # Not implemented.
  Alternative = 16_i64
  # When this flag is set, the result linked-list (Node::next/prev)
  # traverses all nodes in the lattice.
  AllMorphs = 32_i64
  # When this flag is set, tagger internally copies the body of passed
  # sentence into internal buffer.
  AllocateSentence = 64_i64

  # The token boundary is not specified.
  AnyBoundary = 0_i64
  # The position is a strong token boundary.
  TokenBoundary = 1_i64
  # The position is not a token boundary.
  InsideToken = 2_i64

  # C wrapper of MeCab::Tagger::create(argc, argv)
  fun new = mecab_new(argc : LibC::Int, argv : LibC::Char**) : T
  type T = Void*
  # C wrapper of MeCab::Tagger::create(arg)
  fun new2 = mecab_new2(arg : LibC::Char*) : T
  # C wrapper of MeCab::Tagger::version()
  fun version = mecab_version : LibC::Char*
  # C wrapper of MeCab::getLastError()
  fun strerror = mecab_strerror(mecab : T) : LibC::Char*
  # C wrapper of MeCab::deleteTagger(tagger)
  fun destroy = mecab_destroy(mecab : T)
  # C wrapper of MeCab::Tagger:set_partial()
  fun get_partial = mecab_get_partial(mecab : T) : LibC::Int
  # C wrapper of MeCab::Tagger::partial()
  fun set_partial = mecab_set_partial(mecab : T, partial : LibC::Int)
  # C wrapper of MeCab::Tagger::theta()
  fun get_theta = mecab_get_theta(mecab : T) : LibC::Float
  # C wrapper of  MeCab::Tagger::set_theta()
  fun set_theta = mecab_set_theta(mecab : T, theta : LibC::Float)
  # C wrapper of MeCab::Tagger::lattice_level()
  fun get_lattice_level = mecab_get_lattice_level(mecab : T) : LibC::Int
  # C wrapper of MeCab::Tagger::set_lattice_level()
  fun set_lattice_level = mecab_set_lattice_level(mecab : T, level : LibC::Int)
  # C wrapper of MeCab::Tagger::all_morphs()
  fun get_all_morphs = mecab_get_all_morphs(mecab : T) : LibC::Int
  # C wrapper of MeCab::Tagger::set_all_moprhs()
  fun set_all_morphs = mecab_set_all_morphs(mecab : T, all_morphs : LibC::Int)
  # C wrapper of MeCab::Tagger::parse(MeCab::Lattice *lattice)
  fun parse_lattice = mecab_parse_lattice(mecab : T, lattice : LatticeT) : LibC::Int
  type LatticeT = Void*
  # C wrapper of MeCab::Tagger::parse(const char *str)
  fun sparse_tostr = mecab_sparse_tostr(mecab : T, str : LibC::Char*) : LibC::Char*
  # C wrapper of MeCab::Tagger::parse(const char *str, size_t len)
  fun sparse_tostr2 = mecab_sparse_tostr2(mecab : T, str : LibC::Char*, len : LibC::SizeT) : LibC::Char*
  # C wrapper of MeCab::Tagger::parse(const char *str, char *ostr, size_t olen)
  fun sparse_tostr3 = mecab_sparse_tostr3(mecab : T, str : LibC::Char*, len : LibC::SizeT, ostr : LibC::Char*, olen : LibC::SizeT) : LibC::Char*
  # C wrapper of MeCab::Tagger::parseToNode(const char *str)
  fun sparse_tonode = mecab_sparse_tonode(mecab : T, x1 : LibC::Char*) : NodeT*
  # C wrapper of MeCab::Tagger::parseToNode(const char *str, size_t len)
  fun sparse_tonode2 = mecab_sparse_tonode2(mecab : T, x1 : LibC::Char*, x2 : LibC::SizeT) : NodeT*
  # C wrapper of MeCab::Tagger::parseNBest(size_t N, const char *str)
  fun nbest_sparse_tostr = mecab_nbest_sparse_tostr(mecab : T, n : LibC::SizeT, str : LibC::Char*) : LibC::Char*
  # C wrapper of MeCab::Tagger::parseNBest(size_t N, const char *str, size_t len)
  fun nbest_sparse_tostr2 = mecab_nbest_sparse_tostr2(mecab : T, n : LibC::SizeT, str : LibC::Char*, len : LibC::SizeT) : LibC::Char*
  # C wrapper of MeCab::Tagger::parseNBest(size_t N, const char *str, char *ostr, size_t olen)
  fun nbest_sparse_tostr3 = mecab_nbest_sparse_tostr3(mecab : T, n : LibC::SizeT, str : LibC::Char*, len : LibC::SizeT, ostr : LibC::Char*, olen : LibC::SizeT) : LibC::Char*
  # C wrapper of MeCab::Tagger::parseNBestInit(const char *str)
  fun nbest_init = mecab_nbest_init(mecab : T, str : LibC::Char*) : LibC::Int
  # C wrapper of MeCab::Tagger::parseNBestInit(const char *str, size_t len)
  fun nbest_init2 = mecab_nbest_init2(mecab : T, str : LibC::Char*, len : LibC::SizeT) : LibC::Int
  # C wrapper of MeCab::Tagger::next()
  fun nbest_next_tostr = mecab_nbest_next_tostr(mecab : T) : LibC::Char*
  # C wrapper of MeCab::Tagger::next(char *ostr, size_t olen)
  fun nbest_next_tostr2 = mecab_nbest_next_tostr2(mecab : T, ostr : LibC::Char*, olen : LibC::SizeT) : LibC::Char*
  # C wrapper of MeCab::Tagger::nextNode()
  fun nbest_next_tonode = mecab_nbest_next_tonode(mecab : T) : NodeT*
  # C wrapper of MeCab::Tagger::formatNode(const Node *node)
  fun format_node = mecab_format_node(mecab : T, node : NodeT*) : LibC::Char*
  # C wrapper of MeCab::Tagger::dictionary_info()
  fun dictionary_info = mecab_dictionary_info(mecab : T) : DictionaryInfoT*
  # C wrapper of MeCab::createLattice()
  fun lattice_new = mecab_lattice_new : LatticeT
  # C wrapper of MeCab::deleteLattice(lattice)
  fun lattice_destroy = mecab_lattice_destroy(lattice : LatticeT)
  # C wrapper of MeCab::Lattice::clear()
  fun lattice_clear = mecab_lattice_clear(lattice : LatticeT)
  # C wrapper of MeCab::Lattice::is_available()
  fun lattice_is_available = mecab_lattice_is_available(lattice : LatticeT) : LibC::Int
  # C wrapper of MeCab::Lattice::bos_node()
  fun lattice_get_bos_node = mecab_lattice_get_bos_node(lattice : LatticeT) : NodeT*
  # C wrapper of MeCab::Lattice::eos_node()
  fun lattice_get_eos_node = mecab_lattice_get_eos_node(lattice : LatticeT) : NodeT*
  # C wrapper of MeCab::Lattice::begin_nodes()
  fun lattice_get_all_begin_nodes = mecab_lattice_get_all_begin_nodes(lattice : LatticeT) : NodeT**
  # C wrapper of MeCab::Lattice::end_nodes()
  fun lattice_get_all_end_nodes = mecab_lattice_get_all_end_nodes(lattice : LatticeT) : NodeT**
  # C wrapper of MeCab::Lattice::begin_nodes(pos)
  fun lattice_get_begin_nodes = mecab_lattice_get_begin_nodes(lattice : LatticeT, pos : LibC::SizeT) : NodeT*
  # C wrapper of MeCab::Lattice::end_nodes(pos)
  fun lattice_get_end_nodes = mecab_lattice_get_end_nodes(lattice : LatticeT, pos : LibC::SizeT) : NodeT*
  # C wrapper of MeCab::Lattice::sentence()
  fun lattice_get_sentence = mecab_lattice_get_sentence(lattice : LatticeT) : LibC::Char*
  # C wrapper of MeCab::Lattice::set_sentence(sentence)
  fun lattice_set_sentence = mecab_lattice_set_sentence(lattice : LatticeT, sentence : LibC::Char*)
  # C wrapper of MeCab::Lattice::set_sentence(sentence, len)
  fun lattice_set_sentence2 = mecab_lattice_set_sentence2(lattice : LatticeT, sentence : LibC::Char*, len : LibC::SizeT)
  # C wrapper of MeCab::Lattice::size()
  fun lattice_get_size = mecab_lattice_get_size(lattice : LatticeT) : LibC::SizeT
  # C wrapper of MeCab::Lattice::Z()
  fun lattice_get_z = mecab_lattice_get_z(lattice : LatticeT) : LibC::Double
  # C wrapper of MeCab::Lattice::set_Z()
  fun lattice_set_z = mecab_lattice_set_z(lattice : LatticeT, z : LibC::Double)
  # C wrapper of MeCab::Lattice::theta()
  fun lattice_get_theta = mecab_lattice_get_theta(lattice : LatticeT) : LibC::Double
  # C wrapper of MeCab::Lattice::set_theta()
  fun lattice_set_theta = mecab_lattice_set_theta(lattice : LatticeT, theta : LibC::Double)
  # C wrapper of MeCab::Lattice::next()
  fun lattice_next = mecab_lattice_next(lattice : LatticeT) : LibC::Int
  # C wrapper of MeCab::Lattice::request_type()
  fun lattice_get_request_type = mecab_lattice_get_request_type(lattice : LatticeT) : LibC::Int
  # C wrapper of MeCab::Lattice::has_request_type()
  fun lattice_has_request_type = mecab_lattice_has_request_type(lattice : LatticeT, request_type : LibC::Int) : LibC::Int
  # C wrapper of MeCab::Lattice::set_request_type()
  fun lattice_set_request_type = mecab_lattice_set_request_type(lattice : LatticeT, request_type : LibC::Int)
  # C wrapper of MeCab::Lattice::add_request_type()
  fun lattice_add_request_type = mecab_lattice_add_request_type(lattice : LatticeT, request_type : LibC::Int)
  # C wrapper of MeCab::Lattice::remove_request_type()
  fun lattice_remove_request_type = mecab_lattice_remove_request_type(lattice : LatticeT, request_type : LibC::Int)
  # C wrapper of MeCab::Lattice::newNode();
  fun lattice_new_node = mecab_lattice_new_node(lattice : LatticeT) : NodeT*
  # C wrapper of MeCab::Lattice::toString()
  fun lattice_tostr = mecab_lattice_tostr(lattice : LatticeT) : LibC::Char*
  # C wrapper of MeCab::Lattice::toString(buf, size)
  fun lattice_tostr2 = mecab_lattice_tostr2(lattice : LatticeT, buf : LibC::Char*, size : LibC::SizeT) : LibC::Char*
  # C wrapper of MeCab::Lattice::enumNBestAsString(N)
  fun lattice_nbest_tostr = mecab_lattice_nbest_tostr(lattice : LatticeT, n : LibC::SizeT) : LibC::Char*
  # C wrapper of MeCab::Lattice::enumNBestAsString(N, buf, size)
  fun lattice_nbest_tostr2 = mecab_lattice_nbest_tostr2(lattice : LatticeT, n : LibC::SizeT, buf : LibC::Char*, size : LibC::SizeT) : LibC::Char*
  # C wrapper of MeCab::Lattice::has_constraint()
  fun lattice_has_constraint = mecab_lattice_has_constraint(lattice : LatticeT) : LibC::Int
  # C wrapper of MeCab::Lattice::boundary_constraint(pos)
  fun lattice_get_boundary_constraint = mecab_lattice_get_boundary_constraint(lattice : LatticeT, pos : LibC::SizeT) : LibC::Int
  # C wrapper of MeCab::Lattice::feature_constraint(pos)
  fun lattice_get_feature_constraint = mecab_lattice_get_feature_constraint(lattice : LatticeT, pos : LibC::SizeT) : LibC::Char*
  # C wrapper of MeCab::Lattice::boundary_constraint(pos, type)
  fun lattice_set_boundary_constraint = mecab_lattice_set_boundary_constraint(lattice : LatticeT, pos : LibC::SizeT, boundary_type : LibC::Int)
  # C wrapper of MeCab::Lattice::set_feature_constraint(begin_pos, end_pos, feature)
  fun lattice_set_feature_constraint = mecab_lattice_set_feature_constraint(lattice : LatticeT, begin_pos : LibC::SizeT, end_pos : LibC::SizeT, feature : LibC::Char*)
  # C wrapper of MeCab::Lattice::set_result(result);
  fun lattice_set_result = mecab_lattice_set_result(lattice : LatticeT, result : LibC::Char*)
  # C wrapper of MeCab::Lattice::what()
  fun lattice_strerror = mecab_lattice_strerror(lattice : LatticeT) : LibC::Char*
  # C wapper of MeCab::Model::create(argc, argv)
  fun model_new = mecab_model_new(argc : LibC::Int, argv : LibC::Char**) : ModelT
  type ModelT = Void*
  # C wapper of MeCab::Model::create(arg)
  fun model_new2 = mecab_model_new2(arg : LibC::Char*) : ModelT
  # C wapper of MeCab::deleteModel(model)
  fun model_destroy = mecab_model_destroy(model : ModelT)
  # C wapper of MeCab::Model::createTagger()
  fun model_new_tagger = mecab_model_new_tagger(model : ModelT) : T
  # C wapper of MeCab::Model::createLattice()
  fun model_new_lattice = mecab_model_new_lattice(model : ModelT) : LatticeT
  # C wrapper of MeCab::Model::swap()
  fun model_swap = mecab_model_swap(model : ModelT, new_model : ModelT) : LibC::Int
  # C wapper of MeCab::Model::dictionary_info()
  fun model_dictionary_info = mecab_model_dictionary_info(model : ModelT) : DictionaryInfoT*
  # C wrapper of MeCab::Model::transition_cost()
  fun model_transition_cost = mecab_model_transition_cost(model : ModelT, rc_attr : LibC::UShort, lc_attr : LibC::UShort) : LibC::Int
  # C wrapper of MeCab::Model::lookup()
  fun model_lookup = mecab_model_lookup(model : ModelT, begin : LibC::Char*, _end : LibC::Char*, lattice : LatticeT) : NodeT*
  fun do = mecab_do(argc : LibC::Int, argv : LibC::Char**) : LibC::Int
  fun dict_index = mecab_dict_index(argc : LibC::Int, argv : LibC::Char**) : LibC::Int
  fun dict_gen = mecab_dict_gen(argc : LibC::Int, argv : LibC::Char**) : LibC::Int
  fun cost_train = mecab_cost_train(argc : LibC::Int, argv : LibC::Char**) : LibC::Int
  fun system_eval = mecab_system_eval(argc : LibC::Int, argv : LibC::Char**) : LibC::Int
  fun test_gen = mecab_test_gen(argc : LibC::Int, argv : LibC::Char**) : LibC::Int
end
