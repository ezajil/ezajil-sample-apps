import { Component, EventEmitter, Input, Output } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { User } from 'ezajil-js-sdk';
import { DataService } from '../data.service';

@Component({
  selector: 'app-username-selection-modal',
  templateUrl: './username-selection-modal.component.html',
  styleUrls: ['./username-selection-modal.component.scss']
})
export class UsernameSelectionModalComponent {
  @Input() showModal!: boolean;
  @Output() userSelected: EventEmitter<User> = new EventEmitter<User>();
  userForm: FormGroup;
  userOptions: [string, string][] = Array.from(DataService.users.entries());

  constructor() {
    this.userForm = new FormGroup({
      userId: new FormControl('', [Validators.required])
    });
  }

  openModal() {
    this.showModal = true;
  }

  closeModal() {
    this.showModal = false;
  }

  onSubmit() {
    if (this.userForm.valid) {
      const selectedUserId = this.userForm.get('userId')?.value;
      const username = DataService.users.get(selectedUserId);
      this.userSelected.emit(new User(selectedUserId, username || 'unknown'));
      this.closeModal();
    }
  }
}
