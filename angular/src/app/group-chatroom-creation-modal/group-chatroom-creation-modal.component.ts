import { Component, ElementRef, EventEmitter, Input, OnInit, Output, Renderer2 } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { User } from 'ezajil-js-sdk';
import { GroupChatroomParams } from '../models/GroupChatroomParams';
import { DataService } from '../data.service';

@Component({
  selector: 'app-group-chatroom-creation-modal',
  templateUrl: './group-chatroom-creation-modal.component.html',
  styleUrls: ['./group-chatroom-creation-modal.component.scss']
})
export class GroupChatroomCreationModalComponent implements OnInit {
  @Input() showModal!: boolean;
  @Input() currentUser!: User;
  @Output() groupChatroomParams: EventEmitter<GroupChatroomParams> = new EventEmitter<GroupChatroomParams>();
  groupChatroomForm: FormGroup;

  get availableParticipants(): [string, string][] {
    return Array.from(DataService.users.entries()).filter(user => this.currentUser.userId !== user[0]);
  }

  constructor(private renderer: Renderer2, private el: ElementRef) {
    this.groupChatroomForm = new FormGroup({
      name: new FormControl('', [Validators.required]),
      participants: new FormControl(null, [Validators.required]),
    });
  }

  ngOnInit() {
    // Listen for clicks outside the modal and close it
    // this.renderer.listen('window', 'click', (event: Event) => {
    //   if (this.showModal && !this.el.nativeElement.contains(event.target)) {
    //     this.closeModal();
    //   }
    // });
  }

  openModal() {
    this.showModal = true;
  }

  closeModal() {
    this.showModal = false;
  }

  onSubmit() {
    if (this.groupChatroomForm.valid) {
      this.groupChatroomParams.emit(
        new GroupChatroomParams(this.groupChatroomForm.get('name')?.value, this.groupChatroomForm.get('participants')?.value)
      );
      this.closeModal();
    }
  }
}
