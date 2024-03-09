import { Component, EventEmitter, Input, Output } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { User } from 'ezajil-js-sdk';
import { SingleChatroomParams } from '../models/SingleChatroomParams';
import { DataService } from '../data.service';

@Component({
  selector: 'app-single-chatroom-creation-modal',
  templateUrl: './single-chatroom-creation-modal.component.html',
  styleUrls: ['./single-chatroom-creation-modal.component.scss']
})
export class SingleChatroomCreationModalComponent {
  @Input() showModal!: boolean;
  @Input() currentUser!: User;
  @Output() singleChatroomParams: EventEmitter<SingleChatroomParams> = new EventEmitter<SingleChatroomParams>();
  singleChatroomForm: FormGroup;
  
  get availableParticipants(): [string, string][] {
    return Array.from(DataService.users.entries()).filter(user => this.currentUser.userId !== user[0]);
  }

  constructor() {
    this.singleChatroomForm = new FormGroup({
      name: new FormControl('', [Validators.required]),
      participant: new FormControl(null, [Validators.required]),
    });
  }

  openModal() {
    this.showModal = true;
  }

  closeModal() {
    this.showModal = false;
  }

  onSubmit() {
    if (this.singleChatroomForm.valid) {
      this.singleChatroomParams.emit(
        new SingleChatroomParams(this.singleChatroomForm.get('name')?.value, this.singleChatroomForm.get('participant')?.value)
      );
      this.closeModal();
    }
  }
}
