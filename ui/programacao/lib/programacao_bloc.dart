import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:programacao/programacao_state.dart';

class ProgramacaoCubit extends Cubit<ProgramacaoState> {
  ProgramacaoCubit() : super(const ProgramacaoLoading());

  void load() => emit(const ProgramacaoSuccess());

  /// "Participando": show only the events the user joined.
  void setParticipatingOnly(bool participatingOnly) =>
      emit(ProgramacaoSuccess(participatingOnly: participatingOnly));
}
