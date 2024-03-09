import { Component, Input, OnInit } from '@angular/core';
import { Session, User } from 'ezajil-js-sdk';

@Component({
  selector: 'app-main',
  templateUrl: './main.component.html',
  styleUrls: ['./main.component.scss']
})
export class MainComponent implements OnInit {
  @Input() currentUser!: User;
  session!: Session;
  isOnline!: boolean;
  clientError!: string;

  ngOnInit(): void {
    const endpoint = 'api.ezajil.io'; //'localhost:8080';
    const apiKey = 'Do6W+pDF+HhJh0tbGp4Z45We27n4N2p87GYF0LeeD1vNn3n8aWzveD0msln8CCeF3GLl1c4ebga3p9fwg0tO0sfFwkH14BcjKhFyrUbq8U8cMI6icJ+3HgfIWeLuFoji'
    this.session = new Session(endpoint, apiKey, this.currentUser, {enableLogging: true});
    this.session
      .on('connected', () => {
        this.isOnline = true;
      })
      .on('disconnected', (code: number, reason: string, isClientError: boolean) => {
        this.isOnline = false;
        if (isClientError) {
          this.clientError = `${reason} (${code})`;
        }
      })
      .on('error', (event: Event) => {
        console.error(`error: ${JSON.stringify(event)}`);
      });
      this.session.connect();
  }

}
