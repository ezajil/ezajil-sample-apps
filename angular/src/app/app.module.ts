import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { HttpClientModule } from '@angular/common/http';

import { AppComponent } from './app.component';
import { ChatboxComponent } from './chatbox/chatbox.component';
import { MainComponent } from './main/main.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { SidebarComponent } from './sidebar/sidebar.component';
import { UsernameSelectionModalComponent } from './username-selection-modal/username-selection-modal.component';
import { GroupChatroomCreationModalComponent } from './group-chatroom-creation-modal/group-chatroom-creation-modal.component';
import { SingleChatroomCreationModalComponent } from './single-chatroom-creation-modal/single-chatroom-creation-modal.component';
import { ToastrModule } from 'ngx-toastr';

@NgModule({
  declarations: [
    AppComponent,
    ChatboxComponent,
    MainComponent,
    SidebarComponent,
    UsernameSelectionModalComponent,
    SingleChatroomCreationModalComponent,
    GroupChatroomCreationModalComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    FormsModule,
    ReactiveFormsModule,
    ToastrModule.forRoot({
      timeOut: 10000,
      positionClass: 'toast-top-right',
      preventDuplicates: true,
    }),
    HttpClientModule,
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
