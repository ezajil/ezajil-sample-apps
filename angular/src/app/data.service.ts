import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class DataService {
  static users: Map<string, string> = new Map([
    ['1', 'ezajil1'],
    ['2', 'ezajil2'],
    ['3', 'ezajil3'],
    ['4', 'ezajil4'],
    ['5', 'ezajil5'],
    ['6', 'ezajil6'],
    ['7', 'ezajil7'],
    ['8', 'ezajil8'],
    ['9', 'ezajil9'],
    ['10', 'ezajil10'],
    ['11', 'ezajil11'],
  ]);
}
