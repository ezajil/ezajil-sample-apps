import { Component, ViewChild } from '@angular/core';
import { UsernameSelectionModalComponent } from './username-selection-modal/username-selection-modal.component';
import { User } from 'ezajil-js-sdk';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  @ViewChild(UsernameSelectionModalComponent) 
  modalComponent?: UsernameSelectionModalComponent;
  selectedUser?: User;

  onSelectedUser(user: User) {
    this.selectedUser = user;
  }

}
