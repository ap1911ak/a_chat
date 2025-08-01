import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get current user ID
import '../../../../core/error/failures.dart';
// ignore: unused_import
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/contact.dart';
import '../../domain/usecases/add_contact_usecase.dart';
import '../../domain/usecases/get_contacts_usecase.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final GetContactsUseCase getContactsUseCase;
  final AddContactUseCase addContactUseCase;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance; // Directly access for current user ID

  StreamSubscription<List<ContactEntity>>? _contactsSubscription;

  ContactsBloc({
    required this.getContactsUseCase,
    required this.addContactUseCase,
  }) : super(ContactsInitial()) {
    on<GetContactsEvent>(_onGetContacts);
    on<ContactsUpdatedEvent>(_onContactsUpdated);
    on<AddContactEvent>(_onAddContact);
  }

  Future<void> _onGetContacts(
    GetContactsEvent event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsLoading());
    _contactsSubscription?.cancel(); // Cancel previous subscription

    final result = await getContactsUseCase(event.userId);
    result.fold(
      (failure) => emit(ContactsError(_mapFailureToMessage(failure))),
      (stream) {
        _contactsSubscription = stream.listen(
          (contacts) => add(ContactsUpdatedEvent(contacts)),
          onError: (error) => emit(ContactsError(error.toString())),
        );
      },
    );
  }

  void _onContactsUpdated(
    ContactsUpdatedEvent event,
    Emitter<ContactsState> emit,
  ) {
    emit(ContactsLoaded(event.contacts));
  }

  Future<void> _onAddContact(
    AddContactEvent event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsLoading()); // Show loading while adding
    final currentUserId = firebaseAuth.currentUser!.uid;

    final result = await addContactUseCase(
      AddContactParams(
        currentUserId: currentUserId,
        contactEmail: event.contactEmail,
      ),
    );
    result.fold(
      (failure) => emit(ContactsError(_mapFailureToMessage(failure))),
      (_) {
        emit(ContactAddedSuccess());
        // After success, re-fetch contacts to update the list
        add(GetContactsEvent(currentUserId));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
    // ignore: type_literal_in_constant_pattern
    case ServerFailure:
      // ตรวจสอบว่า message ไม่เป็น null
      return (failure as ServerFailure).message;
    default:
      // ควรมีข้อความ default ที่เหมาะสมเสมอ
      return 'Unexpected error occurred. Please try again.';
  }
  }

  @override
  Future<void> close() {
    _contactsSubscription?.cancel();
    return super.close();
  }
}